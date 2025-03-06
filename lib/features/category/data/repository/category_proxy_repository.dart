import 'package:circle_share/core/common/internet_checker/connectivity_checker.dart';
import 'package:circle_share/core/error/failure.dart';
import 'package:circle_share/features/category/data/repository/category_local_repository.dart';
import 'package:circle_share/features/category/data/repository/category_remote_repository.dart';
import 'package:circle_share/features/category/domain/entity/category_entity.dart';
import 'package:circle_share/features/category/domain/repository/category_repository.dart';
import 'package:dartz/dartz.dart';

class CategoryRepositoryProxy implements ICategoryRepository {
  final ConnectivityListener connectivityListener;
  final CategoryRemoteRepository remoteRepository;
  final CategoryLocalRepository localRepository;

  CategoryRepositoryProxy({
    required this.connectivityListener,
    required this.remoteRepository,
    required this.localRepository,
  });

  @override
  Future<Either<Failure, void>> addCategory(CategoryEntity category) async {
    if (await connectivityListener.isConnected) {
      try {
        print("Connected to the internet");
        return await remoteRepository.addCategory(category);
      } catch (e) {
        print("Remote call failed, falling back to local storage");
        return await localRepository.addCategory(category);
      }
    } else {
      print("No internet, saving category locally");
      return await localRepository.addCategory(category);
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    if (await connectivityListener.isConnected) {
      try {
        print("Connected to the internet");

        final categories = await remoteRepository.getCategories();
        // TODO: Consider saving to local storage for offline use
        return categories;
      } catch (e) {
        print("Remote call failed, falling back to local storage");
        return await localRepository.getCategories();
      }
    } else {
      print("No internet, retrieving categories from local storage");
      return await localRepository.getCategories();
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String categoryId) async {
    if (await connectivityListener.isConnected) {
      try {
        print("Connected to the internet");
        return await remoteRepository.deleteCategory(categoryId);
      } catch (e) {
        print("Remote call failed, falling back to local storage");
        return await localRepository.deleteCategory(categoryId);
      }
    } else {
      print("No internet, deleting category locally");
      return await localRepository.deleteCategory(categoryId);
    }
  }
}
