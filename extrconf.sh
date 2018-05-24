#!/bin/bash

source $HOME/.bash_profile

function do_merge_array(){
 eval local -a array_clust=(`echo $1 | tr -s ',' ' '`)
 eval local -a array_passw=(`echo $2 | tr -s ',' ' '`)
 eval local -a pair_val=()
 local -i i
for (( i=0 ; i < ${#array_clust[@]}  ; i++ ))
do
  pair_val+=( ${array_clust[$i]}","${array_passw[$i]})
done

echo "${pair_val[@]}"
}

declare -a my_url=()

my_url=("sample1.cfm.ops.google.jp" "sample2.cfm.ops.google.jp")
my_url=(`cat ./configurations.txt | xargs`)
my_url=`(do_merge_array "sample1.cfm.ops.google.jp,sample2.cfm.ops.google.jp" "AAAAAAAA,BBBBBBBBBB")`

declare -a my_array=()

my_array=("iaas_configulation" "director_configuration" "availability_zones" "networks" "director/az_and_network_assignment" "secret_tokens" "director/syslog" "director/resources")

repo_nm=`date '+%m%d%H%M'`

mkdir -p $HOME/gitwork
cd $HOME/gitwork/

git init
git clone https://xxxx.xxxx.xxxx.git
cd $HOME/gitwork/pcf-conf

git branch ${repo_nm}
git checkout ${repo_nm}

for urlandpass in ${my_url[@]}; do
	hnmae=`echo ${urlandpass} | cut -d "." -f1`
	t_url=`echo ${urlandpass} | cut -d "," -f1`
	my_passwd=`echo ${urlandpass} | cut -d "," -f2`

v_name=`om --target https://${t_url} --clientp_id `` --client_secret '' --username admin --password ${my_passwd} --skip-ssl-validation curl --silent --path /api/diagnostic_report | jq -r 'versions.release_version'` 

		for e in ${my_array[@]}; do
			if[! -e ./opsman]; then
				mkdir -p ./opsman/ 2>dev/null
			fi

			cd ./opsman
			if[! -e ./${hname}]; then
				mkdir -p ./cf_${hname}/ 2>dev/null
			fi
			cd ./cf_${hname}
			if[! -e ./${e#director/}; then
				mkdir -p ./${e#director/} 2>dev/null
			fi

		cd ../../
		echo -e "$(om -k --target https://${t_url} -u admin --password ${my_passwd} curl --path https://${t_url}/infrastructure/${e}/edit)" > ./opsman/cf_${hname}/${e#director/}/latest2.html

		sed -e "/
/d" ./opsman/cf_${hname}/${e#director/}/latest2.html ./opsman/cf_${hname}/${e#director/}/latest3.html

cat ./opsman/cf_${hname}/${e#director/}/latest3.html | sed -e "password/N;s/$1\n.*//g -e "password/N.s/$1//g > ./opsman/cf_${hname}/${e#director/}/latest.html

cd $HOME/gitwork/pcf_conf/
cp ./opsman/cf_${hname}/${e#director/}/latest.html ./opsman/cf_${hname}/${e#director/}/"opsman-"${e#director/}"-"$[v_name}.html

rm -f ./opsman/cf_${hname}/${e#director/}/latest2.html ./opsman/cf_${hname}/${e#director/}/latest3.html
		done
done

cd $HOME/gitwork/pcf-conf/

git add.
git commit -m "差分チェック"${repo_nm}
git pull origin ${repo_nm}

git push --set -upstream origin ${repo_nm} --force

rm -Rf $HOME/gitwork


exit 0

