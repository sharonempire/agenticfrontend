import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/course/course.dart';
import '../../repositories/interfaces/course_repository.dart';

abstract class CourseDetailEvent extends Equatable {
  const CourseDetailEvent();
  @override List<Object?> get props => [];
}
class CourseDetailFetched extends CourseDetailEvent {
  const CourseDetailFetched(this.courseId);
  final String courseId;
  @override List<Object?> get props => [courseId];
}

enum CourseDetailStatus { initial, loading, loaded, error }

class CourseDetailState extends Equatable {
  const CourseDetailState({this.status = CourseDetailStatus.initial, this.course, this.errorMessage});
  final CourseDetailStatus status;
  final Course? course;
  final String? errorMessage;
  @override List<Object?> get props => [status, course, errorMessage];
}

class CourseDetailBloc extends Bloc<CourseDetailEvent, CourseDetailState> {
  CourseDetailBloc(this._repo) : super(const CourseDetailState()) {
    on<CourseDetailFetched>(_onFetched);
  }
  final CourseRepository _repo;

  Future<void> _onFetched(CourseDetailFetched event, Emitter<CourseDetailState> emit) async {
    emit(const CourseDetailState(status: CourseDetailStatus.loading));
    try {
      final course = await _repo.getCourseById(event.courseId);
      emit(CourseDetailState(status: CourseDetailStatus.loaded, course: course));
    } catch (e) {
      emit(CourseDetailState(status: CourseDetailStatus.error, errorMessage: '$e'));
    }
  }
}
