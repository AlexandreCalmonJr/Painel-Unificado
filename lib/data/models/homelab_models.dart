/// Modelos de dados para o sistema Homelab

class AIModel {
  final String id;
  final String name;
  final String type; // 'LLM', 'Image Gen', 'Audio'
  final String size;
  final String quantization;
  final String status; // 'loaded', 'downloaded', 'downloading', 'stopped'
  final String lastUsed;
  final int? progress; // Para downloads em andamento

  AIModel({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.quantization,
    required this.status,
    required this.lastUsed,
    this.progress,
  });

  factory AIModel.fromJson(Map<String, dynamic> json) {
    return AIModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      size: json['size'] as String,
      quantization: json['quantization'] as String,
      status: json['status'] as String,
      lastUsed: json['lastUsed'] as String,
      progress: json['progress'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'size': size,
      'quantization': quantization,
      'status': status,
      'lastUsed': lastUsed,
      'progress': progress,
    };
  }
}

class GPUStats {
  final String name;
  final int vramTotal; // MB
  final int vramUsed; // MB
  final int utilization; // %
  final int temp; // Celsius
  final int power; // Watts

  GPUStats({
    required this.name,
    required this.vramTotal,
    required this.vramUsed,
    required this.utilization,
    required this.temp,
    required this.power,
  });

  factory GPUStats.fromJson(Map<String, dynamic> json) {
    return GPUStats(
      name: json['name'] as String,
      vramTotal: json['vramTotal'] as int,
      vramUsed: json['vramUsed'] as int,
      utilization: json['utilization'] as int,
      temp: json['temp'] as int,
      power: json['power'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'vramTotal': vramTotal,
      'vramUsed': vramUsed,
      'utilization': utilization,
      'temp': temp,
      'power': power,
    };
  }
}

class ContainerData {
  final int id;
  final String name;
  final String image;
  final String status;
  final String port;
  final String cpu;
  final String mem;
  final String uptime;

  ContainerData({
    required this.id,
    required this.name,
    required this.image,
    required this.status,
    required this.port,
    required this.cpu,
    required this.mem,
    required this.uptime,
  });

  factory ContainerData.fromJson(Map<String, dynamic> json) {
    return ContainerData(
      id: json['id'] as int,
      name: json['name'] as String,
      image: json['image'] as String,
      status: json['status'] as String,
      port: json['port'] as String,
      cpu: json['cpu'] as String,
      mem: json['mem'] as String,
      uptime: json['uptime'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'status': status,
      'port': port,
      'cpu': cpu,
      'mem': mem,
      'uptime': uptime,
    };
  }
}

class BackupJob {
  final String name;
  final String target;
  final String status; // 'success', 'running', 'failed'
  final String time;

  BackupJob({
    required this.name,
    required this.target,
    required this.status,
    required this.time,
  });

  factory BackupJob.fromJson(Map<String, dynamic> json) {
    return BackupJob(
      name: json['name'] as String,
      target: json['target'] as String,
      status: json['status'] as String,
      time: json['time'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'target': target, 'status': status, 'time': time};
  }
}

class IPAMSubnet {
  final int id;
  final String name;
  final String cidr;
  final int usage; // Percentual
  final int vlan;
  final String gateway;

  IPAMSubnet({
    required this.id,
    required this.name,
    required this.cidr,
    required this.usage,
    required this.vlan,
    required this.gateway,
  });

  factory IPAMSubnet.fromJson(Map<String, dynamic> json) {
    return IPAMSubnet(
      id: json['id'] as int,
      name: json['name'] as String,
      cidr: json['cidr'] as String,
      usage: json['usage'] as int,
      vlan: json['vlan'] as int,
      gateway: json['gateway'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cidr': cidr,
      'usage': usage,
      'vlan': vlan,
      'gateway': gateway,
    };
  }
}

class WorkstationAsset {
  final int id;
  final String name;
  final String type; // 'desktop', 'laptop', 'panel'
  final String user;
  final String os;
  final String status;
  final String ip;
  final String? currentUrl; // Para painéis/kiosks

  WorkstationAsset({
    required this.id,
    required this.name,
    required this.type,
    required this.user,
    required this.os,
    required this.status,
    required this.ip,
    this.currentUrl,
  });

  factory WorkstationAsset.fromJson(Map<String, dynamic> json) {
    return WorkstationAsset(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      user: json['user'] as String,
      os: json['os'] as String,
      status: json['status'] as String,
      ip: json['ip'] as String,
      currentUrl: json['currentUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'user': user,
      'os': os,
      'status': status,
      'ip': ip,
      'currentUrl': currentUrl,
    };
  }
}

class CommandLog {
  final int id;
  final String time;
  final String source;
  final String msg;

  CommandLog({
    required this.id,
    required this.time,
    required this.source,
    required this.msg,
  });

  factory CommandLog.fromJson(Map<String, dynamic> json) {
    return CommandLog(
      id: json['id'] as int,
      time: json['time'] as String,
      source: json['source'] as String,
      msg: json['msg'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'time': time, 'source': source, 'msg': msg};
  }
}

class CommandTarget {
  final int id;
  final String name;
  final String group; // 'Servers', 'Workstations', 'Mobile'
  final String ip;
  final String status;

  CommandTarget({
    required this.id,
    required this.name,
    required this.group,
    required this.ip,
    required this.status,
  });

  factory CommandTarget.fromJson(Map<String, dynamic> json) {
    return CommandTarget(
      id: json['id'] as int,
      name: json['name'] as String,
      group: json['group'] as String,
      ip: json['ip'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'group': group, 'ip': ip, 'status': status};
  }
}

class PowerData {
  final UPSData ups;
  final int rackPower; // Watts

  PowerData({required this.ups, required this.rackPower});

  factory PowerData.fromJson(Map<String, dynamic> json) {
    return PowerData(
      ups: UPSData.fromJson(json['ups'] as Map<String, dynamic>),
      rackPower: json['rackPower'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'ups': ups.toJson(), 'rackPower': rackPower};
  }
}

class UPSData {
  final int battery; // %
  final String timeLeft;
  final int load; // %
  final int inputVoltage; // V

  UPSData({
    required this.battery,
    required this.timeLeft,
    required this.load,
    required this.inputVoltage,
  });

  factory UPSData.fromJson(Map<String, dynamic> json) {
    return UPSData(
      battery: json['battery'] as int,
      timeLeft: json['timeLeft'] as String,
      load: json['load'] as int,
      inputVoltage: json['inputVoltage'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'battery': battery,
      'timeLeft': timeLeft,
      'load': load,
      'inputVoltage': inputVoltage,
    };
  }
}

class FileItem {
  final String name;
  final String size;
  final String date;
  final bool isDir;

  FileItem({
    required this.name,
    required this.size,
    required this.date,
    required this.isDir,
  });

  factory FileItem.fromJson(Map<String, dynamic> json) {
    return FileItem(
      name: json['name'] as String,
      size: json['size'] as String,
      date: json['date'] as String,
      isDir: json['isDir'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'size': size, 'date': date, 'isDir': isDir};
  }
}

class AssetImportData {
  final String name;
  final String ip;
  final String type;
  final String location;
  final String model;

  AssetImportData({
    required this.name,
    required this.ip,
    required this.type,
    required this.location,
    required this.model,
  });

  factory AssetImportData.fromJson(Map<String, dynamic> json) {
    return AssetImportData(
      name: json['name'] as String,
      ip: json['ip'] as String,
      type: json['type'] as String,
      location: json['location'] as String,
      model: json['model'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ip': ip,
      'type': type,
      'location': location,
      'model': model,
    };
  }
}

class SystemStats {
  final int cpu;
  final int ram;
  final int storage;
  final int temp;
  final String networkUp;
  final String networkDown;
  final String uptime;
  final int containers;

  SystemStats({
    required this.cpu,
    required this.ram,
    required this.storage,
    required this.temp,
    required this.networkUp,
    required this.networkDown,
    required this.uptime,
    required this.containers,
  });

  factory SystemStats.fromJson(Map<String, dynamic> json) {
    return SystemStats(
      cpu: json['cpu'] as int,
      ram: json['ram'] as int,
      storage: json['storage'] as int,
      temp: json['temp'] as int,
      networkUp: json['networkUp'] as String,
      networkDown: json['networkDown'] as String,
      uptime: json['uptime'] as String,
      containers: json['containers'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cpu': cpu,
      'ram': ram,
      'storage': storage,
      'temp': temp,
      'networkUp': networkUp,
      'networkDown': networkDown,
      'uptime': uptime,
      'containers': containers,
    };
  }
}
