from pathlib import Path
import zipfile,json,hashlib,struct,collections
ROOT=Path(__file__).resolve().parents[1]; OUT=ROOT/'docs/assets/psx-audit'; TEMP=Path('/tmp/dead-letter-asset-audit');TEMP.mkdir(parents=True,exist_ok=True)
def glb(data):
 length,kind=struct.unpack_from('<II',data,12);doc=json.loads(data[20:20+length]); binary=data[28+length:] if len(data)>28+length else b''
 return doc,binary

def dims(data):
 if data.startswith(b'\x89PNG\r\n\x1a\n'):return list(struct.unpack_from('>II',data,16))
 if data.startswith(b'\xff\xd8'):
  i=2
  while i<len(data):
   if data[i]!=255:i+=1;continue
   while data[i]==255:i+=1
   marker=data[i];i+=1
   if marker in [0xd8,0xd9,0x01]:continue
   length=int.from_bytes(data[i:i+2],'big')
   if marker in [0xc0,0xc1,0xc2,0xc3,0xc5,0xc6,0xc7,0xc9,0xca,0xcb,0xcd,0xce,0xcf]:return [int.from_bytes(data[i+5:i+7],'big'),int.from_bytes(data[i+3:i+5],'big')]
   i+=length
 return None
with zipfile.ZipFile(ROOT/'Texturas PSX.zip') as z:
 names=[n for n in z.namelist() if not n.endswith('/') and not n.startswith('__MACOSX/') and Path(n).name!='.DS_Store']
 models=[];textures=[];geom_groups=collections.defaultdict(list)
 for n in names:
  if n.endswith('.glb'):
   data=z.read(n);doc,binary=glb(data);triangles=0;uv_missing=0;primitives=0;vertices=0;gh=hashlib.sha256()
   for mesh in doc.get('meshes',[]):
    for prim in mesh.get('primitives',[]):
     primitives+=1;attrs=prim.get('attributes',{});uv_missing+=int('TEXCOORD_0' not in attrs)
     vertices+=doc['accessors'][attrs['POSITION']]['count']
     count=doc['accessors'][prim['indices']]['count'] if 'indices' in prim else doc['accessors'][attrs['POSITION']]['count']
     triangles+=count//3 if prim.get('mode',4)==4 else max(0,count-2) if prim.get('mode') in [5,6] else 0
     for index in [attrs[k] for k in sorted(attrs)]+([prim['indices']] if 'indices' in prim else []):
      acc=doc['accessors'][index];view=doc['bufferViews'][acc['bufferView']];start=view.get('byteOffset',0)
      gh.update(binary[start:start+view['byteLength']]);gh.update(json.dumps({k:v for k,v in acc.items() if k not in ['name','bufferView']},sort_keys=True).encode())
   gh.update(json.dumps([{k:node[k] for k in ['matrix','translation','rotation','scale','children','mesh'] if k in node} for node in doc.get('nodes',[])],sort_keys=True).encode())
   geom_groups[gh.hexdigest()].append(n)
   models.append({'path':n,'name':Path(n).stem,'category':n.split('/')[-2],'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'geometry_hash':gh.hexdigest(),'meshes':len(doc.get('meshes',[])),'primitives':primitives,'vertices':vertices,'triangles':triangles,'primitives_without_uv0':uv_missing,'materials':len(doc.get('materials',[])),'alpha_modes':[m.get('alphaMode','OPAQUE') for m in doc.get('materials',[])],'double_sided':sum(bool(m.get('doubleSided',False)) for m in doc.get('materials',[])),'emissive_materials':sum(bool(m.get('emissiveFactor') and any(m['emissiveFactor'])) for m in doc.get('materials',[])),'images':[{k:v for k,v in im.items() if k!='bufferView'} for im in doc.get('images',[])],'animations':len(doc.get('animations',[])),'skins':len(doc.get('skins',[])),'asset':doc.get('asset',{})})
  elif n.lower().endswith(('.png','.jpg','.jpeg')):
   data=z.read(n);textures.append({'path':n,'size':dims(data),'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'role':'preview' if ('Preview_' in n or 'thumbnail' in n) else 'texture'})
 summary={'archive':'Texturas PSX.zip','archive_sha256':hashlib.file_digest((ROOT/'Texturas PSX.zip').open('rb'),'sha256').hexdigest(),'archive_bytes':(ROOT/'Texturas PSX.zip').stat().st_size,'logical_file_count':len(names),'extensions':dict(collections.Counter(Path(n).suffix.lower() for n in names)),'glb_categories':dict(collections.Counter(m['category'] for m in models)),'glb_count':len(models),'geometry_groups':len(geom_groups),'glb_triangles':{'min':min(m['triangles'] for m in models),'max':max(m['triangles'] for m in models),'median':sorted(m['triangles'] for m in models)[len(models)//2]},'texture_sizes':dict(collections.Counter(str(t['size']) for t in textures if t['role']=='texture')),'alpha_modes':dict(collections.Counter(mode for m in models for mode in m['alpha_modes'])),'uv_missing_primitives':sum(m['primitives_without_uv0'] for m in models),'animated_glbs':sum(m['animations']>0 for m in models),'skinned_glbs':sum(m['skins']>0 for m in models),'license_paths':[n for n in names if any(w in n.lower() for w in ['license','licence','readme','credit'])]}
 (OUT/'inventory.json').write_text(json.dumps({'summary':summary,'models':models,'images':textures,'geometry_variants':[v for v in geom_groups.values() if len(v)>1],'archive_files':names},indent=2,ensure_ascii=False)+'\n')
 # Private audit sandbox only; no source assets are imported into the game project.
 for n in names:
  if n.endswith('.glb') or '/low-poly_papers_set/' in n:
   target=TEMP/'source'/Path(n);target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(z.read(n))
 print(json.dumps(summary,indent=2))
