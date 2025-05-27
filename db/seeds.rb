books = [
  {
    title: "The Great Gatsby",
    author: "F. Scott Fitzgerald",
    genre: "Fiction",
    isbn: Random.hex(10),
    copies: 10,
    available: true
  },
  {
    title: "1984",
    author: "George Orwell",
    genre: "Dystopian",
    isbn: Random.hex(10),
    copies: 5,
    available: true
  },
  {
    title: "To Kill a Mockingbird",
    author: "Harper Lee",
    genre: "Southern Gothic",
    isbn: Random.hex(10),
    copies: 10,
    available: true
  },
  {
    title: "The Catcher in the Rye",
    author: "J.D. Salinger",
    genre: "Coming-of-age",
    isbn: Random.hex(10),
    copies: 8,
    available: true
  },
  {
    title: "The Lord of the Rings",
    author: "J.R.R. Tolkien",
    genre: "Fantasy",
    isbn: Random.hex(10),
    copies: 12,
    available: true
  },
  {
    title: "The Hobbit",
    author: "J.R.R. Tolkien",
    genre: "Fantasy",
    isbn: Random.hex(10),
    copies: 10,
    available: true
  },
  {
    title: "The Hitchhiker's Guide to the Galaxy",
    author: "Douglas Adams",
    genre: "Science Fiction",
    isbn: Random.hex(10),
    copies: 10,
    available: true
  },
  {
    title: "The Da Vinci Code",
    author: "Dan Brown",
    genre: "Mystery",
    isbn: Random.hex(10),
    copies: 10,
    available: true
  },
  {
    title: "The Alchemist",
    author: "Paulo Coelho",
    genre: "Philosophy",
    isbn: Random.hex(10),
    copies: 10,
    available: true
  }
]

books.each do |book_attrs|
  book = Book.find_or_initialize_by(title: book_attrs[:title])
  book.assign_attributes(book_attrs)
  book.save!
end