cleanup:
	-rm -rf gateways nodes wallets

b:
	ansible-playbook playbook.yml

### VERY DANGEROUS - NEVER MODIFY ####

clean_pvs:
	-oc get pv | grep Released | awk '$$1 {print$$1}' | while read vol; do oc delete pv/$${vol}; done

#### VERY DANGEROUS END #####
wp:
	-oc get pods -n ibp-bc -w
