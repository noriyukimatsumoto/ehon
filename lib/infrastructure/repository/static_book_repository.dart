import '../../domain/entity/book.dart';
import '../../domain/entity/book_category.dart';
import '../../domain/repository/book_repository.dart';

class StaticBookRepository implements BookRepository {
  const StaticBookRepository();

  @override
  Future<List<BookCategory>> fetchCategories() async {
    return const [
      BookCategory(
        id: 'japanese-folktales',
        name: '日本の昔話',
        books: [
          Book(
            id: 'momotaro',
            title: '桃太郎',
            xmlPath: 'assets/momotaro.xml',
            coverImagePath: 'assets/images/cover_momotaro.png',
          ),
          Book(
            id: 'urashima',
            title: '浦島太郎',
            xmlPath: 'assets/momotaro.xml',
            coverImagePath: 'assets/images/cover_urashima.png',
          ),
          Book(
            id: 'issun',
            title: '一寸法師',
            xmlPath: 'assets/momotaro.xml',
            coverImagePath: 'assets/images/cover_issun.png',
          ),
        ],
      ),
      BookCategory(
        id: 'world-fairy-tales',
        name: '世界の童話',
        books: [
          Book(
            id: 'akazukin',
            title: '赤ずきん',
            xmlPath: 'assets/momotaro.xml',
            coverImagePath: 'assets/images/cover_akazukin.png',
          ),
          Book(
            id: 'cinderella',
            title: 'シンデレラ',
            xmlPath: 'assets/momotaro.xml',
            coverImagePath: 'assets/images/cover_cinderella.png',
          ),
        ],
      ),
    ];
  }
}
