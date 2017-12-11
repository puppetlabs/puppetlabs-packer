require 'digest/sha2'
require 'digest/md5'


# Perform an incremental checksum on a file.
def checksum_file(digest, filename, lite = false)
  buffer = lite ? 512 : 4096
  File.open(filename, 'rb') do |file|
    while content = file.read(buffer)
      digest << content
      break if lite
    end
  end

  digest.hexdigest
end


file = ARGV[0]
hash_alg = ARGV[1]

puts "filename: " + file
puts "hash algorithm: " + hash_alg

if hash_alg == "sha256"
  digest = Digest::SHA256.new
elsif hash_alg == "md5"
  digest = Digest::MD5.new
else
  puts "Unsupport hash algorithm"
  exit
end

file_hash_result = checksum_file(digest, file)

puts "File digest: " + file_hash_result
