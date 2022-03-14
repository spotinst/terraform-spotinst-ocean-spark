fmt:
	terraform fmt -recursive .

validate-doc:
	terraform-docs -c .terraform-docs.yml --output-check .

generate-doc:
	terraform-docs -c .terraform-docs.yml .