#!/bin/bash
set -eu

echo '#' > pak5.txt

array=(
https://github.com/comfyanonymous/ComfyUI/raw/refs/heads/master/requirements.txt
https://github.com/Comfy-Org/ComfyUI-Manager/raw/refs/heads/main/requirements.txt
https://github.com/MrForExample/ComfyUI-3D-Pack/raw/bdf8a0261d6e36ca0b24043d66503b6cce1c1eda/requirements.txt
https://github.com/Stability-AI/stable-fast-3d/raw/refs/heads/main/requirements.txt
https://github.com/ltdrdata/was-node-suite-comfyui/raw/refs/heads/main/requirements.txt
https://github.com/edenartlab/eden_comfy_pipelines/raw/refs/heads/main/requirements.txt
https://github.com/kijai/ComfyUI-KJNodes/raw/refs/heads/main/requirements.txt
https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite/raw/refs/heads/main/requirements.txt
https://github.com/ltdrdata/ComfyUI-Impact-Pack/raw/refs/heads/Main/requirements.txt
https://github.com/ltdrdata/ComfyUI-Impact-Subpack/raw/refs/heads/main/requirements.txt
https://github.com/ltdrdata/ComfyUI-Inspire-Pack/raw/refs/heads/main/requirements.txt
https://github.com/cubiq/ComfyUI_essentials/raw/refs/heads/main/requirements.txt
https://github.com/spacepxl/ComfyUI-Image-Filters/raw/refs/heads/main/requirements.txt
)

for line in "${array[@]}";
    do curl -w "\n" -sSL "${line}" >> pak5.txt
done

sed -i '/^#/d' pak5.txt
sed -i 's/[[:space:]]*$//' pak5.txt
sed -i 's/>=.*$//' pak5.txt
sed -i 's/_/-/g' pak5.txt

sort -ufo pak5.txt pak5.txt

# Remove duplicate items, compare to pak4.txt
grep -Fixv -f pak4.txt pak5.txt > temp.txt && mv temp.txt pak5.txt

echo "<pak5.txt> generated. Check before use."
