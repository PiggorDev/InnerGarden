extends Node

var backup_folder = "C:/Users/Vitor/Desktop/BackupsInnerGarden"  # Diretório para backups
var project_path = ProjectSettings.globalize_path("res://")  # Caminho do projeto
var backup_interval = 3600  # 1 hora (em segundos)
var permanent_backup_interval = 21600  # 6 horas (em segundos)
var elapsed_time = 0  # Contador de tempo

func _ready():
	if not DirAccess.dir_exists_absolute(backup_folder):
		DirAccess.make_dir_recursive_absolute(backup_folder)
	set_process(true)  # Ativar processamento contínuo

func _process(delta):
	elapsed_time += delta
	if elapsed_time >= backup_interval:
		create_backup()
		elapsed_time = 0  # Reinicia o contador

func create_backup():
	var timestamp = Time.get_unix_time_from_system()
	var backup_path = backup_folder + "/backup_" + str(timestamp) + "/"
	print("🔄 Criando backup: ", backup_path)

	if DirAccess.make_dir_recursive_absolute(backup_path) != OK:
		print("❌ Falha ao criar diretório de backup: ", backup_path)
		return

	# Copiar arquivos do projeto para o backup
	copy_files_recursive(project_path, backup_path)

	# Criar backup permanente a cada 6 horas
	if timestamp % permanent_backup_interval < backup_interval:
		var perm_backup_path = backup_folder + "/permanent_backup_" + str(timestamp) + "/"
		if DirAccess.make_dir_recursive_absolute(perm_backup_path) == OK:
			copy_files_recursive(project_path, perm_backup_path)
			print("🔒 Backup permanente salvo em: ", perm_backup_path)
		else:
			print("❌ Falha ao criar backup permanente.")

func copy_files_recursive(source_path, dest_path):
	var dir = DirAccess.open(source_path)
	if dir == null:
		print("❌ Diretório não encontrado: ", source_path)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			if file_name != "." and file_name != "..":
				var sub_source = source_path + "/" + file_name
				var sub_dest = dest_path + "/" + file_name
				DirAccess.make_dir_recursive_absolute(sub_dest)
				copy_files_recursive(sub_source, sub_dest)
		else:
			var file_source = source_path + "/" + file_name
			var file_dest = dest_path + "/" + file_name
			copy_file(file_source, file_dest)
		file_name = dir.get_next()
	dir.list_dir_end()

func copy_file(source, destination):
	var input_file = FileAccess.open(source, FileAccess.READ)
	if input_file == null:
		print("❌ Falha ao abrir o arquivo para leitura: ", source)
		return

	var output_file = FileAccess.open(destination, FileAccess.WRITE)
	if output_file == null:
		print("❌ Falha ao criar arquivo de destino: ", destination)
		input_file.close()
		return

	output_file.store_buffer(input_file.get_buffer(input_file.get_length()))
	input_file.close()
	output_file.close()
	print("✅ Arquivo copiado: ", source, " → ", destination)
