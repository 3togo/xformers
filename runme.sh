#! /bin/bash
export PATH="$(realpath "tools")":$PATH
set_gcc.sh 12
. ~/jvenv/bin/activate
# export MAX_JOBS=8
export MAX_JOBS=$(( ($(nproc) > 0) ? ($(nproc) / 6) : 1 ))

export TORCH_CUDA_ARCH_LIST="6.0;6.1;6.2;7.0;7.2;7.5;8.0;8.6"
do_build()
{
pip install torch torchvision torchaudio triton --index-url https://download.pytorch.org/whl/cu121
#find . -maxdepth 1 -name "requirements*.txt" -exec pip install -r {} \;
find . -maxdepth 1 -name "requirements*.txt" -exec pip_very_safe_install.sh {} \;
#pip install --no-dependencies -v .
python setup.py bdist_wheel --universal
}

do_install()
{
# find . -name "*.whl" -exec pip install {} \; 
find . -name "*.whl" -type f -printf '%T@\t%p\n' | sort -nr | head -n 1 | cut -f2-|xargs -I {} pip install -U {}
}

do_build
do_install
