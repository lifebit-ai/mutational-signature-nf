FROM continuumio/miniconda3:4.10.3
LABEL description="Dockerfile containing all the tool dependency for https://github.com/Nik-Zainal-Group/signature.tools.lib " \
      author="sangram@lifebit.ai"

ARG ENV_NAME="base"

RUN apt-get install bash procps

COPY environment.yml /
RUN conda env update -n ${ENV_NAME} -f environment.yml && conda clean -a

# Add conda installation dir to PATH (instead of doing 'conda activate')
ENV PATH /opt/conda/envs/${ENV_NAME}/bin:$PATH

# Dump the details of the installed packages to a file for posterity
RUN conda env export --name ${ENV_NAME} > ${ENV_NAME}_exported.yml

# Initialise bash for conda
RUN conda init bash

# Downloaded https://github.com/Nik-Zainal-Group/signature.tools.lib.dev - commit - 1e5832672a62f9ac9c4c36bc47b76e4ba6206d05
# TODO - Pull and checkout them direcrly from github - Right now can't due to private repo
COPY signature.tools.lib.dev /signature.tools.lib.dev

RUN Rscript -e 'devtools::install("/signature.tools.lib.dev")'

ENV PATH /signature_tool_lib/scripts/signatureFit:$PATH