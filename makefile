.PHONY: test
test:
	make test-unit
	make test-functional
test-unit:
	make test-scheduler-unit
	make test-manager-unit
test-functional:
	make test-scheduler-functional
	make test-manager-functional
test-scheduler-unit:
	julia -e 'using StaffJoy; unit_test()'
test-manager-unit:
	julia -e 'using Manager; unit_test()'
test-scheduler-functional:
	julia -e 'using StaffJoy; functional_test()'
test-manager-functional:
	julia -e 'using Manager; functional_test()'
