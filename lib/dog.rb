class Dog  

    attr_accessor :name, :breed 
    attr_reader :id 

     def initialize(id: nil, name:, breed:)
        @id = id 
        @name = name 
        @breed = breed 
     end   



    def self.create_table #creates the dogs table in the database
       sql = <<-SQL
         CREATE TABLE dogs (
             id INTEGER PRIMARY KEY,
             name TEXT,
             breed TEXT
         );
       SQL
        
       DB[:conn].execute(sql) 
    end 

    def self.drop_table #drops the dogs table from the database
        sql = "DROP TABLE dogs" 
        DB[:conn].execute(sql)
    end 

    def save 
        sql = <<-SQL
          INSERT INTO dogs (name, breed) VALUES (?, ?)
        SQL
       
        DB[:conn].execute(sql, self.name, self.breed) #saves an instance of the dog class to the database 
        @id = DB[:conn].execute( "SELECT last_insert_rowid() FROM dogs")[0][0]  #and then sets the given dogs `id` attribute

        self #returns an instance of the dog class
    end 

    def self.create(hash_attribute) 
        dog = self.new(hash_attribute)
        dog.save 
        dog 
    end 

    def self.new_from_db(row) # creates an instance with corresponding attribute values
        attribute = {
        :id => row[0],
        :name => row[1],
        :breed => row[2]
       } 
       self.new(attribute)
    end 

    def self.find_by_id(id) #returns a new dog object by id
       sql = <<-SQL 
         SELECT * FROM dogs WHERE id = ?
       SQL
    
       DB[:conn].execute(sql, id).map do |row|
        self.new_from_db(row)
       end.first 
    end  

    # creates an instance of a dog if it does not already exist
    # when two dogs have the same name and different breed, it returns the correct dog
    # when creating a new dog with the same name as persisted dogs, it returns the correct dog

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
          SELECT * FROM dogs
          WHERE name = ? AND breed = ?
          SQL
        dog = DB[:conn].execute(sql, name, breed).first
    
        if dog
            new_dog = self.new_from_db(dog)
        else
            new_dog = self.create({:name => name, :breed => breed})
         end
            new_dog
    end 

    def self.find_by_name(name) # returns an instance of dog that matches the name from the DB
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ?
          SQL
        
        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row) 
        end.first
    end 

    def update 
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?" 
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end