# /bin/sh

usage(){
        echo "Usage: $0 <OPTIONS>"
        echo "Required options:"
        echo "  -u $USER                User name"
        echo "  -t <bedrockGitCommit>   Bedrock git tag (Dec15-March15) Eg December 15 -> commit | Jan 1 -> commit "
        echo "  -m <bedrockInstance>    Eg bedrock_mv1_first, bedrock_mv1_second"
        echo "  -p <bedrockPort>        Eg 8088, 8089"
        exit 1
}


bedrockCodeDownload() {

mkdir -p /home/$USER/bedrock
bedrockBaseDir="/home/$USER/bedrock"


echo "................................(installing) bedrock code......................................."

if [ -d $bedrockBaseDir/$bedrockInstance ]; then
    rm -rf $bedrockBaseDir/$bedrockInstance
    git -C $bedrockBaseDir clone  --recursive git@github.com:adini121/bedrock.git $bedrockInstance
else
    git -C $bedrockBaseDir clone  --recursive git@github.com:adini121/bedrock.git $bedrockInstance
fi

git -C $bedrockBaseDir/$bedrockInstance stash
git -C $bedrockBaseDir/$bedrockInstance fetch
git -C $bedrockBaseDir/$bedrockInstance checkout $bedrockGitCommit
git -C $bedrockBaseDir/$bedrockInstance submodule update --init --recursive
}

bedrockConfiguration(){
cd $bedrockBaseDir/$bedrockInstance/
cp bedrock/settings/local.py-dist bedrock/settings/local.py
echo "LESS_BIN = '/usr/local/bin/lessc'" >> bedrock/settings/local.py
}

bedrockInstallation(){
pip install virtualenv
virtualenv $bedrockInstance
source $bedrockInstance/bin/activate
pip install 'pip<7.0'
export LC_CTYPE="en_US.utf-8"
pip install -r requirements/compiled.txt
pip install -r requirements/dev.txt
bin/sync_all

./manage.py runserver 0.0.0.0:$bedrockPort

}


while getopts ":u:t:m:p:" i; do
    case "${i}" in
        u) USER=${OPTARG}
		;;
        t) bedrockGitCommit=${OPTARG}
		;;
		m) bedrockInstance=${OPTARG}
        ;;
        p) bedrockPort=${OPTARG}
    esac
done

shift $((OPTIND - 1))

if [[ $USER == "" || $bedrockGitCommit == "" || $bedrockInstance == "" || $bedrockPort == "" ]]; then
        usage
fi

#..........................................function calls...................................

bedrockCodeDownload

bedrockConfiguration

bedrockInstallation
