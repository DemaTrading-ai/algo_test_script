#!/env/bin/bash

work () {
  local from=$1
  local to=$2
  local config=$3
  local plots=$4
  local html=$5
  targetdir=$(pwd)/output/$config
#  docker run --pull always -v "$(pwd)/strategies:/usr/src/engine/strategies" \
#    -v "$(pwd)/${config}:/usr/src/engine/config.json" \
#    -v "$(pwd)/data/backtesting-data:/usr/src/engine/data/backtesting-data" \
#    --rm dematrading/engine:develop -from $from -to $to -plots=$plots \
#    >>$targetdir/$config.txt

  cp $(pwd)/$config $(pwd)/config.json
  engine -from $from -to $to -plots=$plots

  if [ "$html" = true ] ; then
    cat $targetdir/$config.txt | aha --black --title $config > $targetdir/$config.html
  fi

  sed -i 's/\x1B[@A-Z\\\]^_]\|\x1B\[[0-9:;<=>?]*[-!"#$%&'"'"'()*+,.\/]*[][\\@A-Z^_`a-z{|}~]//g' $targetdir/$config.txt
}

curl -fsSL https://engine-store.ams3.digitaloceanspaces.com/installing_macos.sh | /bin/bash

echo $(pwd)
mkdir output
date_format=$(date +'%Y%m%d')
for config in *.json
  do
    if [ "$config" != "config.json" ]
      then
        echo $config
        mkdir "output/$config"
        if [ -n "$config" ]; then
          echo "BACKTESTING SINGLE CONFIG: ${config}\n\n\n"
          work 20190601 $date_format $config true true
          mkdir "output/$config/plots"
          cp -a ./data/backtesting-data/plots/. "output/$config/plots/"
          cp ./data/backtesting-data/trades_log_*.json "output/$config/"
          sudo rm -r ./data/backtesting-data/plots
          sudo rm ./data/backtesting-data/trades_log_*.json
          work 20200601 $date_format $config false false
          work 20210221 20210228 $config false false
          work 20210428 20210527 $config false false
        fi

        name=$(cat $config |  jq '."strategy-name"' -r)
        strategy=$(grep "class $name" ./strategies/*.py --files-with-matches)
        cp "$strategy" "output/$config/"
        cp "$config" "output/$config/"
    fi
  done

zip -r ./output.zip "output/"
cp ./output.zip "output/"

