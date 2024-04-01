export CURRENT_DB_NAME=old_name
export NEW_DB_NAME=new_name

mkdir -p ${NEW_DB_NAME}
cd ${NEW_DB_NAME}
aws glue get-tables --database-name ${CURRENT_DB_NAME} | \
jq "del(.TableList[] | .DatabaseName, .CreateTime, .UpdateTime, .CreatedBy, .IsRegisteredWithLakeFormation, .CatalogId, .VersionId)" > \
tables_clear.json

for ((i=0;i<38;i++)) ; \
    do cat tables_clear.json | jq ".TableList[$i]" > \
    ${NEW_DB_NAME}/$(cat tables_clear.json | jq -r ".TableList[$i].Name").${NEW_DB_NAME}.json ; \
done
for table in $(find . -maxdepth 1 -type f -printf '%f\n') ; \
    do aws glue create-table --database-name ${NEW_DB_NAME} --table-input "file://$table"; \
done

