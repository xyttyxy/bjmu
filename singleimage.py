from cellpose.models import CellposeModel
from cellpose.io import imread
import numpy as np

root_path = r'D:\Work\tailin\wanghuan\DATA示例\DATA\DRUGS\2022-04-14\20553_sorted\D05\s1\w1'
model_root = r'D:\Work\tailin\wanghuan\DATA示例\DATA\baseline\2022-04-14\20552_sorted\D05\s1\w1'
model = CellposeModel(gpu = False, pretrained_model=model_root+r'\models\CP_20220505_162438')

tps = list(range(1,43))
files = [root_path + r'\TimePoint_{:d}_DRUGS_D05_s1_w1.tif'.format(tp) for tp in tps]
imgs = [imread(f) for f in files]
channels = [[0, 0]]
masks, flows, styles = model.eval(imgs, diameter=None, channels=channels)

out_files = [root_path + r'\TimePoint_{:d}_DRUGS_D05_s1_w1.npy'.format(tp) for tp in tps]

for mask, out_file in zip(masks, out_files):
    np.save(out_file, mask)
    


