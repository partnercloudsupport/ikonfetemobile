import 'package:ikonfete/model/artist.dart';
import 'package:ikonfete/repository/repository.dart';

abstract class ArtistRepository implements Repository<Artist, String> {
  Future<Artist> findByUID(String uid);
  Future<Artist> findByUsername(String username);
  Future<Artist> findByEmail(String email);
}