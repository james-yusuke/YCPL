fn bubble_sort(arr []i32, n i32) {
    for (i: i32 = 0; i < n - 1; i++) {
        for (j: i32 = 0; j < n - i - 1; j++) {
            if arr[j] > arr[j + 1] {
                temp: i32 = arr[j]
                arr[j] = arr[j + 1]
                arr[j + 1] = temp
            }
        }
    }
}

fn main() {
    nums: []i32 := [10, 7, 8, 9, 1, 5]
    n: i32 = len(nums)

    println("Original array:")
    for (i: i32 = 0; i < n; i++) {
        println(nums[i])
    }

    bubble_sort(nums, n)

    println("Sorted array:")
    for (i: i32 = 0; i < n; i++) {
        println(nums[i])
    }
}
