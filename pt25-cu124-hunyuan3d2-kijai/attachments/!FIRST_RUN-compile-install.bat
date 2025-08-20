@REM Edit this to your GPU arch.
@REM You don't need to add the "+PTX". Here it works as a fail-safe (providing forward compatibility).

set TORCH_CUDA_ARCH_LIST=6.1+PTX

@REM ===========================================================================

set CMAKE_ARGS=-DBUILD_opencv_world=ON -DWITH_CUDA=ON -DCUDA_FAST_MATH=ON -DWITH_CUBLAS=ON -DWITH_NVCUVID=ON
set PATH=%PATH%;%~dp0\python_standalone\Scripts

@REM Compile-install PyTorch3D
@REM PyTorch3D on Windows works best through compile-install. Binary-install will fail on some workflows.
@REM e.g. "CUDA error: no kernel image is available for execution on the device"

.\python_standalone\python.exe -s -m pip install --force-reinstall ^
 .\extras\pytorch3d

@REM Compile-install pointnet2_ops for Triplane Gaussian

.\python_standalone\python.exe -s -m pip install --force-reinstall ^
 .\extras\pointnet2_ops

@REM Compile-install simple-knn for Gaussian Splatting

.\python_standalone\python.exe -s -m pip install --force-reinstall ^
 .\extras\simple-knn

@REM Differential Gaussian Rasterization

.\python_standalone\python.exe -s -m pip install --force-reinstall ^
 .\extras\diff-gaussian-rasterization

@REM ===========================================================================
@REM For TRELLIS
@REM Note here we skipped 'utils3d'

@REM vox2seq

.\python_standalone\python.exe -s -m pip install --force-reinstall ^
 .\extras\vox2seq

@REM Differential Octree Rasterization

.\python_standalone\python.exe -s -m pip install ^
 .\extras\diffoctreerast

@REM ===========================================================================
@REM For Hunyuan3DWrapper

.\python_standalone\python.exe -s -m pip install diso

.\python_standalone\python.exe -s -m pip install --force-reinstall ^
 .\ComfyUI\custom_nodes\ComfyUI-Hunyuan3DWrapper\hy3dgen\texgen\custom_rasterizer

.\python_standalone\python.exe -s -m pip install --force-reinstall ^
 .\ComfyUI\custom_nodes\ComfyUI-Hunyuan3DWrapper\hy3dgen\texgen\differentiable_renderer

COPY /Y ".\ComfyUI\custom_nodes\ComfyUI-Hunyuan3DWrapper\hy3dgen\texgen\differentiable_renderer\build\lib.win-amd64-cpython-312\mesh_processor.cp312-win_amd64.pyd" ^
".\ComfyUI\custom_nodes\ComfyUI-Hunyuan3DWrapper\hy3dgen\texgen\differentiable_renderer\mesh_processor.cp312-win_amd64.pyd"

@REM ===========================================================================
@REM Ensure NumPy1

.\python_standalone\python.exe -s -m pip install numpy==1.26.4

@REM ===========================================================================
@REM Copy u2net.onnx to user's home path, to skip download at first start.

IF NOT EXIST "%USERPROFILE%\.u2net\u2net.onnx" (
    IF EXIST ".\extras\u2net.onnx" (
        mkdir "%USERPROFILE%\.u2net" 2>nul
        copy ".\extras\u2net.onnx" "%USERPROFILE%\.u2net\u2net.onnx"
    )
)
