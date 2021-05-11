require 'pry'

class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
            SQL
        
            DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
        DROP TABLE dogs
        SQL

        DB[:conn].execute(sql)
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
            INSERT INTO dogs(name, breed)
            VALUES (?, ?)
            SQL

            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end

    def self.new_from_db(row)
        new_dog = row
        new_dog.id = row[0]
        new_dog.name = row[1]
        new_dog.breed = row [2]
        new_dog        
    end

    def self.find_by_id(id:)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
        LIMIT 1
        SQL

        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?, name, breed")
        if !dog.empty?
            dog_data = [0]
            dog = dog.new(dog_data[0], dog_data[1], dog_data[2])
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end

    def self.find_by_name
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        LIMIT 1
        SQL

        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def update
        sql = "SELECT * FROM dogs SET name = ? AND breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end