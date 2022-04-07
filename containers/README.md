# containers

## build `quay.io/lifebitai/signature_tool_lib`

```
cd signature_tools_lib
git clone https://github.com/Nik-Zainal-Group/signature.tools.lib.dev
cd signature.tools.lib.dev
git checkout 1e5832672a62f9ac9c4c36bc47b76e4ba6206d05 .
cd ..
docker build -t quay.io/lifebitai/utility_scripts:1e58326 .
```

## build `quay.io/lifebitai/utility_scripts`

```
cd utility_scripts
git clone https://github.com/Nik-Zainal-Group/utility.scripts
cd utility.scripts 
git checkout b586275ea1ed41c06ebdfe3514f50708ba303cdf .
cd ..
docker build -t quay.io/lifebitai/utility_scripts:b586275 .
```