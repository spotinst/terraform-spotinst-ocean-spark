#! /bin/bash
isCleaned=''
countWaiting=0
echo "Cleaning ocean-spark components started"
kubectl apply -f ofas-uninstall.yaml
while [ $countWaiting -le 600 ] ; ## timeout after 10 minutes
do
    isCleaned=$(kubectl get jobs ofas-uninstall -n spot-system -o jsonpath='{.status.conditions[?(@.type=="Complete")].status}' | grep True)
    if [ "$isCleaned" != "True" ]; then
        echo "Still working …"
        sleep 10;
        ((countWaiting+=10))
    else
        echo "Cleaning ocean-spark components finished"
        break
    fi
done

if [ "$isCleaned" != "True" ]; then
    echo "Couldn't clean ocean-spark components"
fi