require_relative "../config/environment.rb"

class Student
attr_accessor :name, :grade
attr_reader :id

  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
      create table if not exists students (
        id integer primary key,
        name text,
        grade integer
        )
        SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "drop table students"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        insert into students (name, grade)
        values (?, ?)
        SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("select last_insert_rowid() from students")[0][0]
    end
  end

  def self.create(name, grade)
    new_student = self.new(name, grade)
    new_student.save
    new_student
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    grade = row[2]
    new_student = self.new(id, name, grade)
    new_student
  end

  def self.find_by_name(name)
    sql = "select * from students where name = ?"
    result = DB[:conn].execute(sql, name)[0]
    self.new(result[0], result[1], result[2])
  end

  def update
    sql = "update students set name = ?, grade = ? where id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end

# Remember, you can access your database connection anywhere in this class
#  with DB[:conn]
