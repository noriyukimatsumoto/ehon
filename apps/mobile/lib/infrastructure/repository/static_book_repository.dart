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
            titles: {'ja': '桃太郎', 'en': 'Momotaro'},
            xmlPath: 'assets/momotaro.xml',
            coverImagePath: 'assets/images/cover_momotaro.png',
          ),
          Book(
            id: 'urashima',
            titles: {'ja': '浦島太郎', 'en': 'Urashima Taro'},
            xmlPath: 'assets/momotaro.xml',
            coverImagePath: 'assets/images/cover_urashima.png',
          ),
          Book(
            id: 'issun',
            titles: {'ja': '一寸法師', 'en': 'Issun-boshi'},
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
            titles: {'ja': '赤ずきん', 'en': 'Little Red Riding Hood'},
            xmlPath: 'assets/momotaro.xml',
            coverImagePath: 'assets/images/cover_akazukin.png',
          ),
          Book(
            id: 'cinderella',
            titles: {'ja': 'シンデレラ', 'en': 'Cinderella'},
            xmlPath: 'assets/momotaro.xml',
            coverImagePath: 'assets/images/cover_cinderella.png',
          ),
        ],
      ),
    ];
  }
}
