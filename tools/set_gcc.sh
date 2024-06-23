#! /bin/bash
function do_cmd(){
    echo "$@" 1>&2
    eval "$@"
    [[ $? -ne 0 ]] && echo "do_cmd failed" && exit 1
}

#echo "gcc_newest_version = $gcc_newest_version"
#echo "gpp_newest_version = $gpp_newest_version"
gcc_current_version="$(gcc -dumpversion)"
gpp_current_version="$(g++ -dumpversion)"

if [[ $1 -gt 0 ]]; then
    gcc_working_version="${1-12}"
    gpp_working_version="$gcc_working_version"
    gcc_priority=1000
    gpp_priority=1000
else
    gcc_working_version="$(ls -1 /usr/bin/gcc-*|grep 'gcc-[0-9]\+'|sort -V|tail -n1|cut -d '-' -f2)"
    gpp_working_version="$(ls -1 /usr/bin/g++-*|grep 'g++-[0-9]\+'|sort -V|tail -n1|cut -d '-' -f2)"
    gcc_priority="${gcc_working_version}0"
    gpp_priority="${gpp_working_version}0"
fi



echo "gcc_current_version = ${gcc_current_version}"
echo "gpp_current_version = ${gpp_current_version}"
echo "gcc_working_version = ${gcc_working_version}"
echo "gpp_working_version = ${gpp_working_version}"

if [[ "${gcc_working_version}" -ne "${gcc_current_version}" ]]; then
    do_cmd sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${gcc_current_version} ${gcc_current_version}0
    do_cmd sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${gcc_working_version} ${gcc_priority}
    do_cmd sudo update-alternatives --set gcc /usr/bin/gcc-${gcc_working_version}

fi
if [[ "${gpp_working_version}" -ne "${gpp_current_version}" ]]; then
    do_cmd sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-${gpp_current_version} ${gpp_current_version}0
    do_cmd sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-${gpp_working_version} ${gpp_priority}
    do_cmd sudo update-alternatives --set g++ /usr/bin/g++-${gpp_working_version}

fi
