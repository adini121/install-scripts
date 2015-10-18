# /bin/sh

usage(){
        echo "Usage: $0 <OPTIONS>"
        echo "Required options:"
        echo "  -u $USER               user name"
        echo "  -t <FireplaceGitTag>      Fireplace git tag eg: v2.7.1, v2.7.0"
        echo "  -m <FireplaceInstance>    Eg Fireplace_first, Fireplace_second"
        exit 1
}


fireplaceCodeDownload() {

mkdir -p /home/$USER/Fireplace
FireplaceBaseDir="/home/$USER/Fireplace"


echo "................................(installing) fireplace code......................................."

if [ ! -d $FireplaceBaseDir/$fireplaceInstance ]; then
    git -C $FireplaceBaseDir clone https://github.com/mozilla/fireplace.git $fireplaceInstance
fi
 git -C $FireplaceBaseDir/$fireplaceInstance pull
}

fireplaceConfiguration(){
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cp {CURRENT_DIR}/settings_local.js $FireplaceBaseDir/$fireplaceInstance/src/media/js
}

fireplaceInstallation(){
cd $FireplaceBaseDir/$fireplaceInstance/
npm install
make install
MKT_PORT=$FireplacePort make serve

}


while getopts ":u:t:m:p:" i; do
    case "${i}" in
        u) USER=${OPTARG}
		;;
        t) FireplaceGitTag=${OPTARG}
		;;
		m) FireplaceInstance=${OPTARG}
        ;;
        p) FireplacePort=${OPTARG}
    esac
done

shift $((OPTIND - 1))

if [[ $USER == "" || $FireplaceGitTag == "" || $FireplaceInstance == "" || $FireplacePort == "" ]]; then
        usage
fi

#..........................................function calls...................................

fireplaceCodeDownload

fireplaceConfiguration

fireplaceInstallation
