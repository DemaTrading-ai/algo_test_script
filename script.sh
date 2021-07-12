#!/env/bin/bash

work () {
  local from=$1
  local to=$2
  local config=$3
  targetdir=$(pwd)/output/$config
  docker run -v "$(pwd)/strategies:/usr/src/engine/strategies" \
    -v "$(pwd)/${config}:/usr/src/engine/config.json" \
    -v "$(pwd)/data/backtesting-data:/usr/src/engine/data/backtesting-data" \
    --rm dematrading/engine:develop -from $from -to $to -plots=false  \
    >>$targetdir/$config.txt
  sed -i 's/\x1B[@A-Z\\\]^_]\|\x1B\[[0-9:;<=>?]*[-!"#$%&'"'"'()*+,.\/]*[][\\@A-Z^_`a-z{|}~]//g' $targetdir/$config.txt
}

echo "TEST"
mkdir output
for config in *.json
  do
    if [ "$config" != "config.json" ]
      then
        echo $config
        mkdir "output/$config"
#        /bin/bash ./.dema/script.sh $config "$(pwd)/output/$config"
        if [ -n "$config" ]; then
          echo "BACKTESTING SINGLE CONFIG: ${config}\n\n\n"
          work 20200601 20210625 $config
          work 20210221 20210228 $config
          work 20210415 20210424 $config
        fi

        name=$(cat $config |  jq '."strategy-name"' -r)
        strategy=$(grep "class $name" ./strategies/*.py --files-with-matches)
        cp "$strategy" "output/$config/"
    fi
  done

