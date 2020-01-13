import os
import random 
import pandas as pd
import csv
import shutil
path='D:\\Projectmobile\maplaos\mapdataset\ອຸດົມໄຊ'
arr = os.listdir(path)
name_photo=[]
lication_id=[]
data = pd.read_csv("location_import.csv")  
  
# foreach csv location_import csv and rename folder add id behide floder 
for col in data.iterrows(): 
    print(col[1]['loc_name_la']) 
    for n in arr:
        if str(n)==str(col[1]['loc_name_la']):
            #rename folde
            os.rename(path+'/'+ n,path+'/'+n+'_'+str(col[1]['id']))

#foreach directory location floder            
for n in arr:
    #print (n.split('_', 1)[-1])
    if os.path.isdir(path+'/'+ n):
        arr1 = os.listdir(path+'/'+ n)
        for d in arr1:
            name=str(random.randint(0,99999999999))+'_'+str(n.split('_', 1)[-1])+'.'+(d.split('.', 1)[-1]).lower()
            #os.rename(path+'/'+ n+'/'+d,path+'/'+'all_img'+'/'+name)
            shutil.copy(path+'/'+ n+'/'+d,path+'/'+'all_img'+'/'+name)
            name_photo.append(name)
            lication_id.append(str(n.split('_', 1)[-1]))

filename = f"{path}/file_import.csv"
df = pd.DataFrame(list(zip(*[name_photo, lication_id]))).add_prefix('Col')
df.to_csv(filename, index=False)