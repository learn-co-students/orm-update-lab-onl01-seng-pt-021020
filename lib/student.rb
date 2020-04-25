require_relative "../config/environment.rb"

class Student
  attr_reader :grade, :id
  attr_accessor :name

  # class methods
  def self.create(name, grade)
    student = self.new(name, grade)
    student.save
    student
  end
    
  def self.create_table
    sql = <<~SQL
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
	name TEXT,
	grade TEXT
      );
    SQL

    DB[:conn].execute(sql)[0]
  end

  def self.drop_table
    sql = <<~SQL
      DROP TABLE IF EXISTS students;
    SQL

    DB[:conn].execute(sql)
  end

  def self.find_by_name(name)
    sql = <<~SQL
      SELECT *
      FROM students
      WHERE name = ?;
    SQL

    new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def self.new_from_db(row)
    self.new(row[1], row[2], id=row[0])
  end


  # instance methods
  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def save
    if @id.nil?
      sql = <<~SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?);
      SQL

      DB[:conn].execute(sql, @name, @grade)

      @id = DB[:conn].execute('SELECT last_insert_rowid() FROM students')[0][0]

    else
      update
    end
  end

  def update
    sql = <<~SQL
      UPDATE students
      SET (name, grade) = (?, ?)
      WHERE id = ?;
    SQL

    DB[:conn].execute(sql, @name, @grade, @id)
  end

end
