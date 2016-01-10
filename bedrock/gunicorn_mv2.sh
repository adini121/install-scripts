# /bin/sh

usage(){
        echo "Usage: $0 <OPTIONS>"
        echo "Required options:"
        echo "  -u $USER                  user name"
        echo "  -t <bedrockGitCommit>      bedrock git tag (Dec15-March15 eg: December 15 -> commit | Jan 1 -> commit "
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
#sed -i 's|.*DEBUG.*|DEBUG=False|g' bedrock/settings/local.py
#sed -i '/DEBUG=False/a\HMAC_KEYS = {\x272013-01-01\x27: \x27prositneujahr\x27}' bedrock/settings/local.py
#sed -i '/DEBUG=False/a\ALLOWED_HOSTS = [\x27134.96.235.47\x27]' bedrock/settings/local.py
}

bedrockInstallation(){
pip install virtualenv
virtualenv $bedrockInstance
source $bedrockInstance/bin/activate
pip install 'pip<7.0'
export LC_CTYPE="en_US.utf-8"
bin/peep.py install -r requirements/dev.txt
pip install gunicorn
bin/sync_all
/usr/bin/expect <<EOD
set timeout 100
spawn ./manage.py collectstatic
expect "Type 'yes' to continue, or 'no' to cancel:"
send "yes\r"
expect eof
EOD
#./manage.py runserver 0.0.0.0:$bedrockPort
gunicorn wsgi.app:application -b 0.0.0.0:$bedrockPort

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
