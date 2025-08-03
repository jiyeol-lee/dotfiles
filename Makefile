# ---------- CONFIG -------------------------------------------------
TEMPFILE	 := $(TMPDIR)__jiyeollee_dotfiles_secrets_$(shell date +%s)
# clear-text file you edit
PLAINTEXT  := $(TMPDIR)__jiyeollee_dotfiles_secrets_exports
# encrypted blob you commit
CIPHERTEXT := .exports.enc
# PBKDF2 iteration count
KDF_ITERS  := 100000
# algorithm + 256-bit key
CIPHER     := -aes-256-cbc
OPENSSL    := openssl enc $(CIPHER) -salt -pbkdf2 -iter $(KDF_ITERS)
DECRYPTED_TEXT := .decrypted-exports
# ------------------------------------------------------------------

.PHONY: help load-secrets encrypt-secrets rotate-secrets decrypt-secrets

help:
	@echo "Usage: make [target]"
	@echo
	@echo "Targets:"
	@echo "- load-secrets         link $(PLAINTEXT) to ~/.$(DECRYPTED_TEXT) (decrypts if needed)"
	@echo "- encrypt-secrets      encrypt $(PLAINTEXT) → $(CIPHERTEXT) with a new passphrase"
	@echo "- rotate-secrets       re-encrypt $(CIPHERTEXT) with a *new* passphrase (no cleartext on disk)"
	@echo "- decrypt-secrets      decrypt $(CIPHERTEXT) → $(PLAINTEXT) (local inspection/editing)"
	@echo

load-secrets:
	@set -e ; set -o pipefail ; \
	if [ ! -f "$(PLAINTEXT)" ]; then \
		make decrypt-secrets ; \
	fi ; \
	if [ -f "$(PLAINTEXT)" ]; then \
		ln -sf $(PLAINTEXT) $(DECRYPTED_TEXT) ; \
	fi ; \

encrypt-secrets:
	@set -e ; set -o pipefail ; \
	printf "Passphrase: " ; \
	read -r -s NEW_PASS ; echo ; \
	env NEW_PASS="$$NEW_PASS" $(OPENSSL) \
		-pass env:NEW_PASS -in $(PLAINTEXT) -out $(CIPHERTEXT)

rotate-secrets:
	@set -e ; set -o pipefail ; \
	printf "Old passphrase: " ; \
	read -r -s OLD_PASS ; echo ; \
	printf "New passphrase: " ; \
	read -r -s NEW_PASS ; echo ; \
	env OLD_PASS="$$OLD_PASS" $(OPENSSL) -d \
	    -pass env:OLD_PASS -in $(CIPHERTEXT) | \
	env NEW_PASS="$$NEW_PASS" $(OPENSSL) \
	    -pass env:NEW_PASS -out $(CIPHERTEXT).new ; \
	mv $(CIPHERTEXT).new $(CIPHERTEXT)

decrypt-secrets:
	@set -e ; set -o pipefail ; \
	printf "Current passphrase: " ; \
	read -r -s CUR_PASS ; echo ; \
	if env CUR_PASS="$$CUR_PASS" $(OPENSSL) -d \
		-pass env:CUR_PASS -in $(CIPHERTEXT) -out $(TEMPFILE) ; then \
		mv $(TEMPFILE) $(PLAINTEXT) ; \
	fi
