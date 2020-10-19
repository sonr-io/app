part of 'data_bloc.dart';

abstract class DataEvent extends Equatable {
  const DataEvent();

  @override
  List<Object> get props => [];
}

// Pick file to transfer to peer
class QueueFile extends DataEvent {
  final Map info;
  final File file;
  const QueueFile({this.info, this.file});
}

// Send Transfer over DataChannel to Peer
class Transfer extends DataEvent {
  final Peer match;
  const Transfer(this.match);
}

// Add File Chunk from Transfer
class AddChunk extends DataEvent {
  final Uint8List chunk;
  const AddChunk(this.chunk);
}

// Progress Cubit
class ProgressCubit extends Cubit<double> {
  ProgressCubit() : super(0);

  void update(double newValue) {
    // Change Value
    emit(newValue);
  }
}

// Write Completed File to Disk
class WriteFile extends DataEvent {
  final File file;
  const WriteFile({this.file});
}

// Search for a file
class FindFile extends DataEvent {
  const FindFile();
}

// Opens a file in appropriate viewer
class OpenFile extends DataEvent {
  final Metadata meta;
  const OpenFile(this.meta);
}
