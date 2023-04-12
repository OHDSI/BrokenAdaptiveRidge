# @file PackageMaintenance
#
# Copyright 2023 Observational Health Data Sciences and Informatics
#
# This file is part of BrokenAdaptiveRidge
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Format and check code:
OhdsiRTools::formatRFolder()
OhdsiRTools::checkUsagePackage("BrokenAdaptiveRidge")
OhdsiRTools::updateCopyrightYearFolder()

# Create manual and vignettes:
Create manual and website
if (.Platform$OS.type == "unix") {
  system("rm extras/BrokenAdaptiveRidge.pdf")
  system("R CMD Rd2pdf ./ --output=extras/BrokenAdaptiveRidge.pdf")
} else {
  unlink("extras/BrokenAdaptiveRidge.pdf")
  shell("R CMD Rd2pdf ./ --output=extras/BrokenAdaptiveRidge.pdf")
}

pkgdown::build_site()
OhdsiRTools::fixHadesLogo()
