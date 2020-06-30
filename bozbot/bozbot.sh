# Script to check if mongod is up as a proxy of if a harvest is in progress.

trap ctrl_c INT
function ctrl_c() {
    curl -X POST -H 'Content-type: applicati/json' --data '{"text":"IEUVM: BozBot down, user interrupt."}' https://hooks.slack.com/services/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
    exit 0;
}

curl -X POST -H 'Content-type: applicati/json' --data '{"text":"IEUVM: BozBot up."}' https://hooks.slack.com/services/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

# set booleans
running=0;
up=0;
while true;
do
    if [ `pgrep mongod | wc -l` == 0 ] && [ $running == 1 ] 
    then
        if [ `pgrep epicosm_ | wc -l` == 0 ]
            then
                # catch if goes down while harvesting
                curl -X POST -H 'Content-type: applicati/json' --data '{"text":"IEUVM: epicosm looks down, interrupted while active."}' https://hooks.slack.com/services/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
                up=0;
            else
                # catch when harvest finished
                curl -X POST -H 'Content-type: applicati/json' --data '{"text":"IEUVM: epicosm harvest finished, waiting for next harvest."}' https://hooks.slack.com/services/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
        fi
        running=0;
    elif [ `pgrep mongod | wc -l` != 0 ] && [ $running == 0 ]
        then
            # catch harvest start
            curl -X POST -H 'Content-type: applicati/json' --data '{"text":"IEUVM: epicosm harvest started."}' https://hooks.slack.com/services/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
            running=1;
            up=1;
    elif [ `pgrep epicosm_ | wc -l` == 0 ] && [ $running == 0 ] && [ $up == 1 ]
        then
            # catch if goes down while NOT harvesting
            curl -X POST -H 'Content-type: applicati/json' --data '{"text":"IEUVM: epicosm looks down, interrupted while idle."}' https://hooks.slack.com/services/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
        up=0;
    fi
    sleep 1;
done

