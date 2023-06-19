# !/bin/bash

##################################################################
#                      Instalação Python                         #
##################################################################

PYTHON_VERSION="3.10.12"  # Altere para a versão desejada do Python
VERSION="3.10"

# Verificar se a versão específica do Python já está instalada
if command -v python${VERSION} &>/dev/null; then
    echo "Python ${PYTHON_VERSION} já está instalado."
else
    # Atualizar o gerenciador de pacotes
    sudo apt update

    # Instalar as dependências necessárias
    sudo apt install -y build-essential zlib1g-dev 
    sudo apt install -y libncurses5-dev libgdbm-dev 
    sudo apt isntall -y libnss3-dev libssl-dev 
    sudo apt isntall -y libreadline-dev libffi-dev wget

    # Baixar o código-fonte do Python
    wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz

    # Extrair o arquivo compactado
    tar -xf Python-${PYTHON_VERSION}.tar.xz

    # Acessar o diretório do código-fonte
    cd Python-${PYTHON_VERSION}

    # Configurar e compilar o Python
    ./configure --enable-optimizations
    make -j $(nproc)

    # Instalar o Python
    sudo make altinstall

    # Limpar os arquivos temporários
    cd ..
    sudo rm -rf Python-${PYTHON_VERSION} Python-${PYTHON_VERSION}.tar.xz

    # Verificar a versão do Python instalada
    echo "Python ${PYTHON_VERSION} instalado com sucesso"
fi

# Verificar se as variáveis de ambiente já estão configuradas
if [[ ":$PATH:" == *":/usr/bin/python${VERSION}:"* ]]; then
    echo "As variáveis de ambiente para Python ${PYTHON_VERSION} já estão configuradas."
else
    if [[ ":$PATH:" != *":/usr/bin/python${VERSION}:"* ]]; then
        echo "export PATH=/usr/bin/python${VERSION}:\$PATH" >> ~/.bashrc
    else
        echo "PATH=/usr/bin/python${VERSION}:\$PATH já esta configurada"
    fi

    if [[ ":$PYTHONPATH:" != *":/usr/bin/python${VERSION}:"* ]]; then
        echo "export PYTHONPATH=\$PYTHONPATH:/usr/bin/python${VERSION}" >> ~/.bashrc
    else
        echo "PATH=/usr/bin/python${VERSION}:\$PATH já esta configurada"
    fi
    source ~/.bashrc
    echo "Configuração das variáveis de ambiente concluída."
fi


##################################################################
#                      Instalação Miniconda                      #
##################################################################

sudo apt update

CONDA_INSTALLER_URL="https://repo.anaconda.com/miniconda/Miniconda3-py310_23.3.1-0-Linux-x86_64.sh"
CONDA_INSTALLER_FILE="Miniconda3-py310_23.3.1-0-Linux-x86_64.sh"
INSTALL_DIR="$HOME/miniconda"

# Verificar se o Miniconda já está instalado
if command -v conda &>/dev/null; then
    echo "O Miniconda já está instalado."
    command conda --version
else
    # Verificar se o instalador do Miniconda já existe
    if [ -f "$CONDA_INSTALLER_FILE" ]; then
        echo "O instalador do Miniconda já existe."
        command conda --version
    else
        # Baixar o instalador do Miniconda
        echo "Baixando o instalador do Miniconda..."
        wget "$CONDA_INSTALLER_URL" -O "$CONDA_INSTALLER_FILE"

        # Executar o instalador do Miniconda
        echo "Instalando o Miniconda..."
        bash "$CONDA_INSTALLER_FILE" -b -p "$INSTALL_DIR"
    fi

    # Configurar as variáveis de ambiente
    echo "Configurando as variáveis de ambiente..."
    echo "export PATH=\"$INSTALL_DIR/bin:\$PATH\"" >> "$HOME/.bashrc"
    source "$HOME/.bashrc"
    conda --version
    echo "Instalação do Miniconda concluída. "
fi

# Criação Ambiente Conda e Instação OpenCV
echo "Iniciando o ambiente Conda..."
cd $HOME/miniconda/
conda init
conda activate base
conda config --set auto_activate_base false
conda env list

# Nome Ambiente Conda
CONDA_ENV_NAME="PV23" # Mude o nome do ambiente caso queire criar um novo ambiente

# Verificar se o ambiente Conda já existe
if conda env list | grep -q "$CONDA_ENV_NAME"; then
    echo "O ambiente Conda '$CONDA_ENV_NAME' já existe."
else
    echo "Criando o ambiente Conda '$CONDA_ENV_NAME'..."
    conda create -y -n "$CONDA_ENV_NAME" -y
fi

##################################################################
#                      Instalação OpenCV                         #
##################################################################

# Mudando o diretorio para ambiente conda
cd $HOME/miniconda/envs/$CONDA_ENV_NAME

# Ativar o ambiente Conda
echo "Ativando o ambiente Conda '$CONDA_ENV_NAME'..."
conda activate "$CONDA_ENV_NAME"

sudo apt update

sudo apt install build-essential cmake git pkg-config libgtk-3-dev \
   libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
   libxvidcore-dev libx264-dev libjpeg-dev libpng-dev libtiff-dev \
   gfortran openexr libatlas-base-dev python3-dev python3-numpy \
   libtbb2 libtbb-dev libdc1394-dev libopenexr-dev \
   libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev

opencv_build="~/opencv_build"

if [-d opencv_build]; then
    cd $opencv_build
else
    mkdir $opencv_build && cd $opencv_build
fi

# Verificar se o Git está instalado
if ! command -v git &>/dev/null; then
    echo "O Git não está instalado. Instalando o Git..."
    sudo apt-get update
    sudo apt-get install git -y

    # Verificar a versão do Git instalada
    echo "Versão do Git:"
    git --version
else
    echo "O Git já está instalado."
    # Verificar a versão do Git instalada
    echo "Versão do Git:"
    git --version
fi

git clone https://github.com/opencv/opencv.git
git clone https://github.com/opencv/opencv_contrib.git

cd ~/$opencv_build/opencv
mkdir -p build && cd build

cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D INSTALL_C_EXAMPLES=ON \
    -D INSTALL_PYTHON_EXAMPLES=ON \
    -D OPENCV_GENERATE_PKGCONFIG=ON \
    -D OPENCV_EXTRA_MODULES_PATH=~/opencv_build/opencv_contrib/modules \
    -D BUILD_EXAMPLES=ON ..

# Numero de Nucleos do computador
NUM_NUCLEOS=$(nproc)
make -j$NUM_NUCLEOS
sudo make install