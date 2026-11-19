# Limite de compilacoes simultaneas para maquinas em que a RAM acaba antes da CPU.
#
# Opcoes (desligadas por padrao: sem elas a compilacao fica exatamente como antes):
#   OPTIONS_LOW_MEMORY_BUILD  ON = o numero de compilacoes simultaneas sai da RAM instalada
#                             (reserva ~1,5 GB para o sistema, uma compilacao a cada ~1,5 GB restante)
#                             e os links rodam um de cada vez.
#   OPTIONS_COMPILE_JOBS      numero fixo de compilacoes simultaneas (vale mais que o calculo pela RAM)
#   OPTIONS_LINK_JOBS         numero fixo de links simultaneos
# So tem efeito com o gerador Ninja. Nao muda nenhuma opcao do compilador.

option(OPTIONS_LOW_MEMORY_BUILD "Limita as compilacoes simultaneas pela RAM instalada" OFF)
set(OPTIONS_COMPILE_JOBS "" CACHE STRING "Compilacoes simultaneas com Ninja (vazio = sem limite)")
set(OPTIONS_LINK_JOBS "" CACHE STRING "Links simultaneos com Ninja (vazio = sem limite)")

set(_tuning_compile_jobs "${OPTIONS_COMPILE_JOBS}")
set(_tuning_link_jobs "${OPTIONS_LINK_JOBS}")

if(OPTIONS_LOW_MEMORY_BUILD)
	if(NOT _tuning_compile_jobs)
		# os arquivos mais pesados destes projetos chegam a ~2 GB no compilador
		cmake_host_system_information(RESULT _tuning_ram_mib QUERY TOTAL_PHYSICAL_MEMORY)
		cmake_host_system_information(RESULT _tuning_cpus QUERY NUMBER_OF_LOGICAL_CORES)
		math(EXPR _tuning_compile_jobs "(${_tuning_ram_mib} - 1536) / 1536")
		if(_tuning_compile_jobs LESS 1)
			set(_tuning_compile_jobs 1)
		endif()
		if(_tuning_compile_jobs GREATER _tuning_cpus)
			set(_tuning_compile_jobs ${_tuning_cpus})
		endif()
	endif()
	if(NOT _tuning_link_jobs)
		set(_tuning_link_jobs 1)
	endif()
endif()

if(CMAKE_GENERATOR MATCHES "Ninja")
	if(_tuning_compile_jobs)
		set_property(GLOBAL APPEND PROPERTY JOB_POOLS "tuning_compile=${_tuning_compile_jobs}")
		set(CMAKE_JOB_POOL_COMPILE tuning_compile)
		message(STATUS "Compilacoes simultaneas limitadas a ${_tuning_compile_jobs}")
	endif()
	if(_tuning_link_jobs)
		set_property(GLOBAL APPEND PROPERTY JOB_POOLS "tuning_link=${_tuning_link_jobs}")
		set(CMAKE_JOB_POOL_LINK tuning_link)
		message(STATUS "Links simultaneos limitados a ${_tuning_link_jobs}")
	endif()
elseif(_tuning_compile_jobs OR _tuning_link_jobs)
	message(STATUS "O limite de compilacoes simultaneas precisa do gerador Ninja; use -j na ferramenta de build")
endif()
