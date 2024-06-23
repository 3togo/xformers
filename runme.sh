#! /bin/bash

set_gcc.sh 12
. ~/jvenv/bin/activate
export MAX_JOBS=8
export TORCH_CUDA_ARCH_LIST="6.0;6.1;6.2;7.0;7.2;7.5;8.0;8.6"
pip install torch torchvision torchaudio triton --index-url https://download.pytorch.org/whl/cu121
#find . -maxdepth 1 -name "requirements*.txt" -exec pip install -r {} \;
find . -maxdepth 1 -name "requirements*.txt" -exec pip_very_safe_install.sh {} \;
#pip install --no-dependencies -v .
python setup.py bdist_wheel --universal
