(ert-deftest test/init ()
  "it writes a Cask file on pallet-init, listing installed packages"
  (test/with-sandbox
   (test/add-servant-package '(package-one (0 0 1)))
   (package-refresh-contents)
   (package-install 'package-one)
   (should (not (f-exists? test/cask-file)))
   (pallet-mode t)
   (pallet-init)
   (should (f-exists? test/cask-file))
   (should (test/cask-file-contains-p "(depends-on \"package-one\")"))))

(ert-deftest test/install ()
  "it installs packages from the Cask file"
  (test/with-sandbox
   (test/add-servant-package '(package-one (0 0 1)))
   (test/create-cask-file-with-servant "(depends-on \"package-one\")")
   (should (not (package-installed-p 'package-one)))
   (pallet-mode t)
   (pallet-install)
   (should (package-installed-p 'package-one))))

(ert-deftest test/update ()
  "it updates packages in the Cask file"
  (test/with-sandbox
   (test/add-servant-package '(package-two (0 0 1)))
   (test/create-cask-file-with-servant "(depends-on \"package-two\")")
   (pallet-mode t)
   (pallet-install)
   (should (package-installed-p 'package-two '(0 0 1)))
   (test/add-servant-package '(package-two (0 0 2)))
   (pallet-update)
   (should (package-installed-p 'package-two '(0 0 2)))))

(ert-deftest test/pack-on-install ()
  "it adds a package to the Cask file on package-install"
  (test/with-sandbox
   (test/add-servant-package '(package-one (0 0 1)))
   (pallet-mode t)
   (pallet-init)
   (should (not (test/cask-file-contains-p "(depends-on \"package-one\")")))
   (package-refresh-contents)
   (package-install 'package-one)
   (should (test/cask-file-contains-p "(depends-on \"package-one\")"))))

(ert-deftest test/pack-on-install-desc ()
  "it responds correctly to package-install when the argument is a package-desc"
  (when (fboundp 'package-desc-create)
    (test/with-sandbox
     (test/add-servant-package '(package-one (0 0 1)))
     (pallet-mode t)
     (pallet-init)
     (should (not (test/cask-file-contains-p "(depends-on \"package-one\")")))
     (package-refresh-contents)
     (package-install (test/package-desc-create '(package-one (0 0 1))))
     (should (test/cask-file-contains-p "(depends-on \"package-one\")")))))

(ert-deftest test/unpack-on-delete ()
  "it removes a package from the Cask file on package-delete ()"
  (test/with-sandbox
   (test/add-servant-package '(package-one (0 0 1)))
   (test/add-servant-package '(package-two (0 0 1)))
   (package-refresh-contents)
   (package-install 'package-one)
   (package-install 'package-two)
   (pallet-mode t)
   (pallet-init)
   (should (test/cask-file-contains-p "(depends-on \"package-one\")"))
   (should (test/cask-file-contains-p "(depends-on \"package-two\")"))
   (test/package-delete '(package-one (0 0 1)))
   (should (test/cask-file-contains-p "(depends-on \"package-two\")"))
   (should (not (test/cask-file-contains-p "(depends-on \"package-one\")")))))
