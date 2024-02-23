
cp .config .config.predefconf
./scripts/kconfig/merge_config.sh .config .config_toolchain
sed -i '3d' .config

readarray -t config_diff <<< $(diff -u .config.predefconf .config)
readarray -t config_toolchain < .config_toolchain

ret=0
# echo "${config_toolchain[@]}"

## now loop through the above array
for a in "${config_diff[@]}"
do

    # skip if line starts with '+++', '---', '@@', ' #'
    if [[ "$a" != "+++"* ]] && [[ "$a" != "---"* ]] && [[ "$a" != "@@"* ]] && [[ "$a" != " #"* ]]; then

        # exit with error if starts with "-"
        if [[ "$a" == "-"* ]]; then
            echo "fixme: .config shouldn't have: $a"
            ret=1;
        fi
        
        # exit with error if new config has been added
        if [[ "$a" == "+C"* ]]; then
            if [[ ! " ${config_toolchain[*]} " =~ " ${a:1} " ]]; then
                echo "fixme: .config doesn't have: $a"
                ret=1;
            fi
        fi

        # exit with error if new config has been added
        if [[ "$a" == "+# "* ]]; then
            if [[ ! " ${config_toolchain[*]} " =~ " ${a:3} " ]]; then
                echo "fixme: .config doesn't have: $a"
                ret=1;
            fi
        fi
    fi
done
exit $ret
