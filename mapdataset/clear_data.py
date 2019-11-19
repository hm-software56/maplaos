import os
import random 
import pandas as pd

path='D:\\Projectmobile\maplaos\map data\Vientiane'
arr = os.listdir(path)
name_photo=[]
lication_id=[]
for n in arr:
    #print (n.split('_', 1)[-1])
    arr1 = os.listdir(path+'/'+ n)
    for d in arr1:
        name=str(random.randint(0,99999999999))+'_'+str(n.split('_', 1)[-1])+'.'+(d.split('.', 1)[-1]).lower()
        os.rename(path+'/'+ n+'/'+d,path+'/'+'all_img'+'/'+name)
        name_photo.append(name)
        lication_id.append(str(n.split('_', 1)[-1]))

filename = f"{path}/file_import.csv"
df = pd.DataFrame(list(zip(*[name_photo, lication_id]))).add_prefix('Col')
df.to_csv(filename, index=False)