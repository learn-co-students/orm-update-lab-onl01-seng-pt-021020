require_relative "../config/environment.rb"

class Student
  
attr_accessor  :name, :grade, :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  
  def initialize(name, grade, id = nil)
    @id = id 
    @name = name 
    @grade = grade
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
    id integer primary key,
    name text,
    grade integer
    
    );
    SQL
    
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = <<-SQL
    DROP TABLE students;
    SQL
    DB[:conn].execute(sql)
  end
  
  
  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
     end
    end
  
  
  def self.create(name, grade)
  student = self.new(name, grade)
  student.save
  student
  end
    
    def self.new_from_db(row)
      output = self.new(row[1],row[2],row[0])
      output
    end
    
    def self.find_by_name(name)
      sql = "select * from students where name = ?"
      output = DB[:conn].execute(sql, name)[0]
      self.new_from_db(output)
    end
    
    def update
      sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
    end
    
end
