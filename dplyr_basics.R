dim(mtcars)
head(mtcars)

# For Rows:
# filter() chooses rows based on column values.
mtcars %>% filter(cyl > 5, carb >= 2)

# slice() chooses rows based on location.
mtcars %>% slice(5:10)
mtcars %>% slice_head(n = 3)
mtcars %>% slice_tail(n = 5)
mtcars %>% slice_sample(n = 5) # randomly selects rows. Use the option prop to choose a certain proportion of the cases.
mtcars %>% slice_min()

# slice_min() and slice_max() select rows with highest or lowest values of a variable. Note that we first must choose only the values which are not NA.
mtcars %>%
    filter(!is.na(hp)) %>%
    slice_max(hp, n = 3)

# arrange() changes the order of the rows.
mtcars %>% arrange(desc(mpg), carb)


# For Columns:
# select() changes whether or not a column is included.
mtcars %>% select(disp:vs)
mtcars %>% select(!(disp:vs))
mtcars %>% select(ends_with("rb")) # starts_with(), ends_with(), matches() and contains() can be used as well

# rename() changes the name of columns.
mtcars %>% rename(horsepower = hp)

# mutate() changes the values of columns and creates new columns.
# starwars %>%
#     mutate(height_m = height / 100) %>%
#     select(height_m, height, everything())

# relocate() changes the order of the columns.
mtcars %>% relocate(wt:vs, .before = cyl)


# For Groups of Rows:
# summarise() collapses a group into a single row.
mtcars %>% summarise(mpg = mean(mpg, na.rm = TRUE))
mtcars %>%
    group_by(mpg, hp) %>%
    select(wt, drat) %>%
    summarise(
        wt = mean(wt, na.rm = TRUE),
        drat = mean(drat, na.rm = TRUE)
    )
