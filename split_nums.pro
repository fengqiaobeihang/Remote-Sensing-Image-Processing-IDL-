pro split_nums
  nums=indgen(10)+1
  random_nums=randomu(seed, 10)
  s=sort(random_nums)
  nums1=nums[s[3:9]]
  nums2=nums[s[0:2]]
  print, 'Part1:', nums1, format='(a7, 7i3)'
  print, 'Part2:', nums2, format='(a7, 3i3)'
end