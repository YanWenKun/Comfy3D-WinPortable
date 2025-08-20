@REM 编辑为你的 GPU 对应架构
@REM 修改时无需保留 "+PTX" ，其用于向前兼容，防止用户忘了该步骤。

set TORCH_CUDA_ARCH_LIST=6.1+PTX

@REM 使用清华 PyPI 源
set PIP_INDEX_URL=https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple

@REM ===========================================================================

set PATH=%PATH%;%~dp0\python_standalone\Scripts
set CMAKE_ARGS=-DBUILD_opencv_world=ON -DWITH_CUDA=ON -DCUDA_FAST_MATH=ON -DWITH_CUBLAS=ON -DWITH_NVCUVID=ON

@REM 编译安装 PyTorch3D
@REM PyTorch3D 对 Windows 不甚友好，所有二进制安装都可能在某个节点报错，极难排查，故最好提前编译安装。

.\python_standalone\python.exe -s -m pip install --force-reinstall ^
 .\extras\pytorch3d

@REM 编译安装 pointnet2_ops ，该组件用于 Triplane Gaussian

.\python_standalone\python.exe -s -m pip install --force-reinstall ^
 .\extras\pointnet2_ops

@REM 编译安装 simple-knn ，该组件用于 Gaussian Splatting

.\python_standalone\python.exe -s -m pip install --force-reinstall ^
 .\extras\simple-knn

@REM Differential Gaussian Rasterization

.\python_standalone\python.exe -s -m pip install --force-reinstall ^
 .\extras\diff-gaussian-rasterization

@REM ===========================================================================
@REM 用于 TRELLIS 的组件
@REM 注意我们跳过了 'utils3d' ，该组件不需要本地重新编译

@REM vox2seq

.\python_standalone\python.exe -s -m pip install --force-reinstall ^
 .\extras\vox2seq

@REM Differential Octree Rasterization

.\python_standalone\python.exe -s -m pip install ^
 .\extras\diffoctreerast

@REM ===========================================================================
@REM 用于 Hunyuan3DWrapper

.\python_standalone\python.exe -s -m pip install diso

.\python_standalone\python.exe -s -m pip install --force-reinstall ^
 .\ComfyUI\custom_nodes\ComfyUI-Hunyuan3DWrapper\hy3dgen\texgen\custom_rasterizer

.\python_standalone\python.exe -s -m pip install --force-reinstall ^
 .\ComfyUI\custom_nodes\ComfyUI-Hunyuan3DWrapper\hy3dgen\texgen\differentiable_renderer

COPY /Y ".\ComfyUI\custom_nodes\ComfyUI-Hunyuan3DWrapper\hy3dgen\texgen\differentiable_renderer\build\lib.win-amd64-cpython-312\mesh_processor.cp312-win_amd64.pyd" ^
".\ComfyUI\custom_nodes\ComfyUI-Hunyuan3DWrapper\hy3dgen\texgen\differentiable_renderer\mesh_processor.cp312-win_amd64.pyd"

@REM ===========================================================================
@REM 确保使用 NumPy1

.\python_standalone\python.exe -s -m pip install numpy==1.26.4

@REM ===========================================================================
@REM 复制 u2net.onnx 到用户主目录下，以免启动时还需下载。

IF NOT EXIST "%USERPROFILE%\.u2net\u2net.onnx" (
    IF EXIST ".\extras\u2net.onnx" (
        mkdir "%USERPROFILE%\.u2net" 2>nul
        copy ".\extras\u2net.onnx" "%USERPROFILE%\.u2net\u2net.onnx"
    )
)
