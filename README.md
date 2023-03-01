# data-skills-06

## Session Overview

### Objectives
At the end of this lesson, participants should be able to:

1. 

### Lesson Resources
* The [`SETUP.md`](SETUP.md) file contains a list of packages required for this lesson
* The [`notebook/`](/notebook) directory contains both the seminar and completed versions of our lesson notebooks

### Extra Resources
* [RStudio cheatsheet](https://www.rstudio.com/resources/cheatsheets/#ide)
* [Markdown Syntax](https://rmarkdown.rstudio.com/authoring_basics.html)
* [RStudio Community](https://community.rstudio.com)
* [*R for Data Science*](http://r4ds.had.co.nz)

## Access Lesson
### Initial Package Installation
We use the `install.packages` function to install modular components of the `R` ecosystem. For instance, to access lesson materials, we'll use the `usethis` package. To install it, we run the following function in our console:

```r
install.packages("usethis")
```

### Download Lesson Materials
With the package installed, you you can download this lesson to your Desktop easily using `usethis`:

```r
usethis::use_course("https://github.com/chris-prener/data-skills-06/archive/master.zip")
```

By using `usethis::use_course`, all of the lesson materials will be downloaded to your computer, automatically extracted, and saved to your desktop. The `data-skills-06-master` project should open automatically afterwards. Windows users will have the data downloaded to their user folder (e.g. `C:/Users/<USERNAME>/`).

### Install Other Packages for Today
In addition to `usethis`, there are a couple of other packages we'll need:

```r
install.packages(c("tidyverse", "here", "janitor", "knitr", "rmarkdown"))
```

If you've already attended some of these sessions, you should have everything you need for today.

Now we're ready to go!

## Contributor Code of Conduct
Please note that this project is released with a [Contributor Code of Conduct](.github/CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.
