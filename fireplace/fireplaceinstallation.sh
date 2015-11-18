# /bin/sh

usage(){
        echo "Usage: $0 <OPTIONS>"
        echo "Required options:"
        echo "  -u $USER                  user name"
        echo "  -t <FireplaceGitTag>      Fireplace git tag eg: 2015.09.08 | 2015.09.15 | 2015.09.22"
        echo "  -m <FireplaceInstance>    Eg Fireplace_first, Fireplace_second"
        echo "  -p <FireplacePort>        Eg 8088, 8089"
        exit 1
}


fireplaceCodeDownload() {

mkdir -p /home/$USER/Fireplace
FireplaceBaseDir="/home/$USER/Fireplace"


echo "................................(installing) fireplace code......................................."

if [ ! -d $FireplaceBaseDir/$FireplaceInstance ]; then
    rm -r $FireplaceBaseDir/$FireplaceInstance
    git -C $FireplaceBaseDir clone https://github.com/mozilla/fireplace.git $FireplaceInstance
fi
 git -C $FireplaceBaseDir/$FireplaceInstance stash
 git -C $FireplaceBaseDir/$FireplaceInstance fetch
 git -C $FireplaceBaseDir/$FireplaceInstance checkout $FireplaceGitTag
}

fireplaceConfiguration(){
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cp $CURRENT_DIR/settings_local.js $FireplaceBaseDir/$FireplaceInstance/src/media/js
sed -i 's|.*PORT:.*|PORT:'$FireplacePort',|g' $FireplaceBaseDir/$FireplaceInstance/config.js
}

fireplaceInstallation(){
cd $FireplaceBaseDir/$FireplaceInstance/
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
