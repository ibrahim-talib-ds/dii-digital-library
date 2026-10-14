/// Route names + storage keys. Single source of truth.
class DiiRoutes {
  DiiRoutes._();

  static const splash           = '/';
  static const login            = '/login';
  static const signup           = '/signup';
  static const home             = '/home';
  static const browse           = '/browse';
  static const bookDetails      = '/book';        // /book/:id
  static const myBooks          = '/my-books';
  static const history          = '/history';
  static const profile          = '/profile';
  static const notifications    = '/notifications';

  // Librarian / admin
  static const librarianDash    = '/librarian';
  static const borrowRequests   = '/librarian/requests';
  static const receiveReturn    = '/librarian/returns';
  static const manageBooks      = '/librarian/books';
  static const students         = '/librarian/students';

  static const adminDash        = '/admin';
  static const manageUsers      = '/admin/users';
  static const manageLibrarians = '/admin/librarians';
  static const reports          = '/admin/reports';
}

class DiiStorage {
  DiiStorage._();

  static const accessToken  = 'dii.access_token';
  static const refreshToken = 'dii.refresh_token';
  static const userId       = 'dii.user_id';
}
