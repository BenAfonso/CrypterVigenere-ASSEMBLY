	

    # Saisie de la cl� par l'utilisateur
    # Texte d'entr�e � encoder :
            # Saisi par l'utilisateur
            # Via un fichier texte
    # Encodage
     
    .data
    inputKey: .asciiz "Entrez une cle d'encodage (50 caracteres maximum): "
    chosenKey: .asciiz "La cle choisie est : "
    firstMenu: .asciiz "Voulez vous encoder (Entrez 1) ou decoder (Entrez 2): "
    cryptChoice: .asciiz "Voulez vous encoder un fichier texte (Entrez 1) ou une phrase (Entrez 2): "
    inputText: .asciiz "\nVeuillez saisir le texte: "
    inputFile: .asciiz "\nVeuillez saisir le nom du fichier texte: "
    file: .asciiz "toto.txt"
    output: .asciiz "output.txt"
    text: .space 1000
    key: .space 50
    keyArray: .space 50
    textArray: .space 1000
    encode: .space 100
     
    .text
     
    #########################################################################
    ######################## PROGRAMME PRINCIPAL ############################
    #########################################################################
     
    main:
            # Appel des routines
            jal menu
            move $s1,$t1
            jal input
            jal affichage
            jal typeEncodageChoix
            move $s2,$t1
            beq $s2,1,cryptFile ## A MAPPER AVEC INPUT DE FICHIERS .TXT
            beq $s2,2,cryptText
            beq $s1,1,encoder
            beq $s1,2,decoder
            beq $s2,1,stockerResultat
            
            
		
            # Fin du programme
            j end
            li $v0,10
           
    #########################################################################
    #################### INTERACTIONS UTILISATEUR ###########################
    #########################################################################
     
    menu:
    	la $a0, firstMenu
    	la $v0,4
    	syscall
    	la $v0,5
    	syscall
    	la $t1,($v0)
    	jr $ra
    # Routine demandant a l'utilisateur de saisir une cle d'encryption
    # Sortie: $t0 : String, Cle d'encryption
    input:
   	subi $sp , $sp , 4 	# Sauvegarde de l'adresse de la routine principale
	sw $ra , ( $sp )
            la $a0,inputKey
            li $v0,4
            syscall
            la $a0,key
            la $a1,50
            li $v0,8
            syscall
            la $a1, keyArray
            jal stockInArray
        lw $ra , ( $sp )	# On restaure l'adresse de la routine principale
	addi $sp , $sp , 4
	jr $ra		# Jump a la routine principale
		
           
     
    #  Routine affichant le choix de l'utilisateur pour la cl�    
    affichage:
            la $a0,chosenKey
            li $v0, 4
            syscall
            la $a0,key
            li $v0,4
            syscall
            jr $ra
     
    # Routine demandant a l'utilisateur s'il veut encoder une phrase ou un fichier texte 	 
    typeEncodageChoix:
            la $a0,cryptChoice
            li $v0,4
            syscall
            li $v0,5
            syscall
            la $t1,($v0)
            jr $ra
           
    #########################################################
    ################## ENCRYPTER TEXTE ######################
    #########################################################
    
    cryptText:
    	subi $sp , $sp , 4
	sw $ra , ( $sp )

        la $a0,inputText	# On demande la saisie d'un texte a l'utilisateur
        li $v0,4
        syscall
        li $a1,100
        la $a0,text	# On stock la phrase dans l'adresse de text (100 octets maximum)
        li $v0,8
        syscall
        la $a1, textArray	# On prepare l'adresse d'accueil (Le tableau)
 	jal stockInArray	# On stock le texte dans le tableau TextArray
 	la $a0, textArray
 	li $v0, 4
 	syscall
 	
	lw $ra , ( $sp )
	addi $sp , $sp , 4
	jr $ra
	
    #########################################################
    ################## ENCRYPTER FICHIER ####################
    #########################################################
    cryptFile:
    			subi $sp, $sp, 4		#allocation m�moire
			sw $ra,($sp)

			li $v0, 4
			la $a0, inputFile			#demande le nom du fichier
			syscall
	
			li $v0, 8
			la $a0, file
			la $a1, 200
			syscall
	
		loopC:				#remplace le "\n" par le caract�re nul pour permettre la reconnaissance de fin de cha�ne
			lb $t0, ($a0)
			beq $t0, 10, changeC
			addiu $a0, $a0, 1
			j loopC
		
		changeC:
			li $t0, 0
			sb $t0, ($a0)
			
			li $v0, 13			#ouvre le fichier demand�
			la $a0, file
			li $a1, 0
			li $a2,0
			syscall		
			move $s0, $v0
			
 		readC:					#lire les 1000 premiers caract�res du fichier
			li $v0, 14
			move $a0, $s0
			la $a1, text
			li $a2, 1000
			syscall		# Lecture du buffer texte
			move $a0,$a1 # a0 Contient Text
			la $a1, textArray	# a1 Contient Array
			jal stockInArray			#appelle la routine pour stocker le contenu du fichier
			
							
			li $v0, 16	# Fermeture du fichier
			move $a0, $s0
			syscall
			lw $ra,($sp)
			addi $sp, $sp, 4		
			jr $ra
		
			

    #########################################################
    #################### STOCKER ###########################
    #########################################################	
			
    stockInArray:
    	move $t0,$a0 #t0 :: TEXT
    	move $t1,$a1 #t1 :: ARRAY
    	
    for2:
  	lb $t2, ($t0)
	sb $t2, ($t1)
	addiu $t0, $t0, 1
	addiu $t1, $t1, 1
	bnez $t2,for2
	move $v0, $t1
	jr $ra
	
    #########################################################
    ################# STOCKER RESULTAT ######################
    #########################################################	
			
    stockerResultat:
    	li $v0, 13			#ouvre le fichier demand�
	la $a0, file
	li $a1, 0
	li $a2,0
	syscall		
	move $s0, $v0
	
	# Ecriture dans le fichier OUTPUT
	
	li $v0,15
	move $a0,$s0
	la $a1,output
	la $a2,1000
	syscall
		
    #########################################################
    #################### ENCODAGE ###########################
    #########################################################
    
    # Cle stockee dans un tableau keyArray
    # Texte stocke dans un tableau textArray
 	encoder:
 		la $t0,textArray # TEXT ARRAY
 		la $t1,keyArray # KEY ARRAY
 		la $t2,encode
	reset: 
		la $t1,keyArray
	for3:	
		lb $t3,($t0) # On prends la valeur courante de textArray et on la met dans $t2
		lb $t4,($t1) # On prends la valeur de la cle courante
		beq $t4,10,reset
		addiu $t1,$t1,1 # On incremente les deux
		addiu $t0,$t0,1	
		beq $t3,10,end	

		add $t4,$t4,$t3
		bge $t4,220,plus2
		bge $t4,127,plus
		
		jal next
	plus:
		addiu $t4,$t4,-94 # Si $t4 est >= 126, on fait -94 CAR -126 + 32 (Offset: 32 ASCII)
		j next
	plus2:
		addiu $t4,$t4,-188 # Si $t4 est >= 220, on fait -188 car -220+32 = 188 (Offset: 32 ASCII)
	next:
		la $a0,($t4) # On affiche la valeur de t3 (cle)
		li $v0,11
		syscall
		sb $a0,encode
		
		# VISIBILITE
		#li $a0,0
		#li $v0,1
		#syscall
		bne $t3,10,for3 #On boucle tant que t2 n'est pas fini (texte)
		j end
		
		
#########################################################
#################### DECODAGE ###########################
#########################################################
    
    # Cl� stock�e dans un tableau keyArray
    # Texte stock� dans un tableau textArray
 	decoder:
 		la $t0,textArray # TEXT ARRAY
 		la $t1,keyArray # KEY ARRAY
 		la $t2,encode
	reset2: 
		la $t1,keyArray
	for4:	
		lb $t3,($t0) # On prends la valeur courante de textArray et on la met dans $t3
		lb $t4,($t1) # On prends la valeur de la cl� courante
		beq $t4,10,reset2
		addiu $t1,$t1,1 # On incr�mente les deux
		addiu $t0,$t0,1	
		beq $t3,10,end	
		# t4 VALEUR DE CLE ASSOCIE A CARACTERE COURANT 
		# OPERATIONS ICI
		neg $t4,$t4
		add $t4,$t3,$t4
		ble $t4,-63,plus3 
		ble $t4,31,plus4
		jal next2
	plus3:
		addiu $t4,$t4,188 # Si $t4 est < -64, on fait +188
		j next2
	plus4:
		addiu $t4,$t4,94 # Si $t4 est < 32, on fait +94
	next2:
		la $a0,($t4) # On affiche la valeur de t4
		li $v0,11
		syscall
		
		# VISIBILITE (Affichage du scancode (ASCII) correspondant Ci dessous)
		#li $a0,0
		#li $v0,1
		#syscall
		bne $t3,10,for4	 #On boucle tant que t2 n'est pas fini (texte)
		j end
		
	
		
 		
   	
   	
   	
    # Fin du programme     
    end:

    
    	

