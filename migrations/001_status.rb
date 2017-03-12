Sequel.migration do 
	up do
		create_table(:status) do
			primary_key :id
			String :status, null: false
		end
	end

	down do
		drop_table(:status)
	end
end