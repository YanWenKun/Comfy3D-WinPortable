#!/bin/bash
set -eux

# Chores
gcs='git clone --depth=1 --no-tags --recurse-submodules --shallow-submodules'
workdir=$(pwd)
python_exe="${workdir}/Comfy3D_WinPortable/python_standalone/python.exe"
export PYTHONPYCACHEPREFIX="${workdir}/pycache2"
export PATH="$PATH:$workdir/Comfy3D_WinPortable/python_standalone/Scripts"

# MKDIRs
mkdir -p "$workdir"/Comfy3D_WinPortable/extras
# Redirect HuggingFace-Hub model folder
export HF_HUB_CACHE="$workdir/Comfy3D_WinPortable/HuggingFaceHub"
mkdir -p "${HF_HUB_CACHE}"
# Redirect Pytorch Hub model folder
export TORCH_HOME="$workdir/Comfy3D_WinPortable/TorchHome"
mkdir -p "${TORCH_HOME}"

# Relocate python_standalone
# This move is intentional. It will fast-fail if anything breaks.
mv  "$workdir"/python_standalone  "$workdir"/Comfy3D_WinPortable/python_standalone

# Download ComfyUI main app
git clone https://github.com/comfyanonymous/ComfyUI.git \
    "$workdir"/Comfy3D_WinPortable/ComfyUI

# Custom Nodes
cd "$workdir"/Comfy3D_WinPortable/ComfyUI/custom_nodes

# 3D-Pack
mv "$workdir"/ComfyUI-3D-Pack ./ComfyUI-3D-Pack

# ComfyUI-Manager
$gcs https://github.com/ltdrdata/ComfyUI-Manager.git

# SF3D
$gcs https://github.com/Stability-AI/stable-fast-3d.git

# Hunyuan3DWrapper
$gcs https://github.com/kijai/ComfyUI-Hunyuan3DWrapper.git
$gcs https://github.com/cubiq/ComfyUI_essentials.git

# Nodes used by 3D-Pack workflows
$gcs https://github.com/cubiq/ComfyUI_IPAdapter_plus.git
$gcs https://github.com/edenartlab/eden_comfy_pipelines.git
$gcs https://github.com/kijai/ComfyUI-KJNodes.git
$gcs https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git
$gcs https://github.com/ltdrdata/ComfyUI-Impact-Pack.git
$gcs https://github.com/ltdrdata/ComfyUI-Impact-Subpack.git
$gcs https://github.com/ltdrdata/ComfyUI-Inspire-Pack.git
$gcs https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git
$gcs https://github.com/ltdrdata/was-node-suite-comfyui.git
$gcs https://github.com/rgthree/rgthree-comfy.git
$gcs https://github.com/chrisgoringe/cg-use-everywhere.git
$gcs https://github.com/spacepxl/ComfyUI-Image-Filters.git
$gcs https://github.com/shinich39/comfyui-get-meta.git
$gcs https://github.com/aria1th/ComfyUI-LogicUtils.git

# Download RealESRGAN_x4plus needed by example workflows
curl -sSL https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth \
    -o "$workdir"/Comfy3D_WinPortable/ComfyUI/models/upscale_models/RealESRGAN_x4plus.pth

# Download models for Impact-Pack & Impact-Subpack
cd "$workdir"/Comfy3D_WinPortable/ComfyUI/custom_nodes/ComfyUI-Impact-Pack
$python_exe -s -B install.py
cd "$workdir"/Comfy3D_WinPortable/ComfyUI/custom_nodes/ComfyUI-Impact-Subpack
$python_exe -s -B install.py

################################################################################
# Run the test (CPU only), also let custom nodes download some models
cd "$workdir"/Comfy3D_WinPortable
./python_standalone/python.exe -s -B "ComfyUI/main.py" --quick-test-for-ci --cpu

################################################################################
# Download u2net model needed by rembg (to avoid download at first start)
curl -sSL https://github.com/danielgatis/rembg/releases/download/v0.0.0/u2net.onnx \
    -o "$workdir"/Comfy3D_WinPortable/extras/u2net.onnx

# Copy/Move example files of 3D-Pack
mkdir -p "$workdir"/Comfy3D_WinPortable/ComfyUI/user/default/workflows
cp -r "$workdir"/Comfy3D_WinPortable/ComfyUI/custom_nodes/ComfyUI-3D-Pack/_Example_Workflows/. \
    "$workdir"/Comfy3D_WinPortable/ComfyUI/user/default/workflows/

rm -rf "$workdir"/Comfy3D_WinPortable/ComfyUI/user/default/workflows/_Example_Inputs_Files
rm -rf "$workdir"/Comfy3D_WinPortable/ComfyUI/user/default/workflows/_Example_Outputs

cp -r "$workdir"/Comfy3D_WinPortable/ComfyUI/custom_nodes/ComfyUI-3D-Pack/_Example_Workflows/_Example_Inputs_Files/. \
    "$workdir"/Comfy3D_WinPortable/ComfyUI/input/

# Copy example input files of SF3D
cp -r "$workdir"/Comfy3D_WinPortable/ComfyUI/custom_nodes/stable-fast-3d/demo_files/examples/. \
    "$workdir"/Comfy3D_WinPortable/ComfyUI/input

# Copy example input files of TRELLIS
cd "$workdir"
curl -sSL https://github.com/microsoft/TRELLIS/archive/refs/heads/main.zip \
    -o TRELLIS-main.zip
unzip -q TRELLIS-main.zip

cp -r TRELLIS-main/assets/example_image/. \
    "$workdir"/Comfy3D_WinPortable/ComfyUI/input/trellis-single

cp -r TRELLIS-main/assets/example_multi_image/. \
    "$workdir"/Comfy3D_WinPortable/ComfyUI/input/trellis-multi

rm TRELLIS-main.zip
rm -rf TRELLIS-main

# Copy example files of Hunyuan3DWrapper
cd "$workdir"/Comfy3D_WinPortable/ComfyUI
mkdir -p user/default/workflows/kijai_Hunyuan3DWrapper
cp ./custom_nodes/ComfyUI-Hunyuan3DWrapper/example_workflows/*.json \
    ./user/default/workflows/kijai_Hunyuan3DWrapper/

################################################################################
# Source files needed by user compile-install
cd "$workdir"/Comfy3D_WinPortable/extras/

mv "$workdir"/Comfy3D_Pre_Builds/_Libs/pointnet2_ops \
    "$workdir"/Comfy3D_WinPortable/extras/pointnet2_ops

mv "$workdir"/Comfy3D_Pre_Builds/_Libs/simple-knn \
    "$workdir"/Comfy3D_WinPortable/extras/simple-knn

mv "$workdir"/Comfy3D_Pre_Builds/_Libs/vox2seq \
    "$workdir"/Comfy3D_WinPortable/extras/vox2seq

# PyTorch3D
curl -sSL https://github.com/facebookresearch/pytorch3d/archive/refs/heads/main.zip \
    -o temp.zip
unzip -q temp.zip
mv pytorch3d-main pytorch3d
rm temp.zip

# Differential Octree Rasterization
$gcs https://github.com/JeffreyXiang/diffoctreerast.git

# Differential Gaussian Rasterization (kiui version)
$gcs https://github.com/ashawkey/diff-gaussian-rasterization.git

################################################################################
# Copy & overwrite attachments
cp -rf "$workdir"/attachments/. \
    "$workdir"/Comfy3D_WinPortable/

# Clean up
rm -vf "$workdir"/Comfy3D_WinPortable/*.log
rm -vrf "$workdir"/Comfy3D_WinPortable/ComfyUI/user/default/ComfyUI-Manager

cd "$workdir"/Comfy3D_WinPortable/ComfyUI/custom_nodes
rm -vf ./was-node-suite-comfyui/was_suite_config.json
rm -vf ./ComfyUI-Impact-Pack/impact-pack.ini

cd "$workdir"/Comfy3D_WinPortable/ComfyUI/custom_nodes/ComfyUI-Manager
git reset --hard
git clean -fxd

cd "$workdir"
